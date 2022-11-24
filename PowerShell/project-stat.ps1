
param (
	[switch]$debug = $false,
	[switch]$projectInfo = $false,
	[switch]$payInfo = $true
)

#把 excel/xls 文件另存为 csv 格式文件
Function Excel2csv {
	$excelFile = $args[0]
	$ncsvFile = $args[1]

	$csvFile = New-TemporaryFile

	$Excel = New-Object -ComObject Excel.Application
	$Excel.DisplayAlerts = $false;
	$wb = $Excel.Workbooks.Open($excelFile)
	$ws0 = @($wb.Worksheets)[0]
	$ws0.SaveAs($csvFile, 6)

	#将 csv 文件编码转换为 UTF-8
	$content = (Get-Content -Path $csvFile)
	Set-Content -Path $ncsvFile -Encoding UTF8 -Value $content

	$Excel.Quit()
	#if (Test-Path -Path $csvFile) { Remove-Item -Path $csvFile }
}

#变量声明
$excelPath = Resolve-Path $args[0]
$csvPath =  "$pwd\data.csv"
$jsonPath =  "$pwd\data.json"
if (Test-Path -Path $csvPath) { Remove-Item -Path $csvPath }
if (Test-Path -Path $jsonPath) { Remove-Item -Path $jsonPath }

#xls 文件转换为 csv 文件
Excel2csv $excelPath $csvPath

#再将 csv 转换为 json 格式
Import-Csv $csvPath -Header Num,Name,Owner,Scale,Value,BenefitSalaryRatio,BenefitSalaryTotal,OwnerRatio,Comment,GrantTime,GrantAmount,GrantComment,ArchiveTime,ArchiveRatio,ArchiveAmount,ArchiveComment,CompletedTime,CompletedRatio,CompletedAmount,CompletedComment,TOLL-finishTime,TOLL-finishRatio,TOLL-finishAmount,TOLL-finishComment,PerformancePay,PerformancePayBalance,Comment2,InnovationIncentive |
	ConvertTo-Json |
	Set-Content -Path $jsonPath

#数据处理
$ProjectArr = @()
$ProjectArray = Get-Content $jsonPath | ConvertFrom-Json
for ($i=0; $i -lt $ProjectArray.Count; $i++) {
	$project = $ProjectArray[$i]
	if (!$project.Num) { continue }
	if ($project.Num -eq "工程编号") { continue }
	$ProjectArr += $project
}

[int]$payedSum = 0
[int]$payedBalanceSum = 0
$edistriSum = @{}
$edistriBalanceSum = @{}

if ($projectInfo) {
	 $ProjectArr
} elseif ($payInfo) {
	for ($i=0; $i -lt $ProjectArr.Count; $i++) {
		$project = $ProjectArr[$i]

		if ($debug) {echo "`n`nProject: 编号:$($project.Num), 名称:$($project.Name)"}

		$payedRatio1, $payedRatio2, $payedRatio3 = 0, 0, 0
		[int]$paysum1, [int]$paysum2, [int]$paysum3 = 0, 0, 0
		if ($debug) {echo "    [成果发放]:$($project.ArchiveRatio), 分配:($($($project.ArchiveComment).replace("`r`n",", ")))"}
		if ($project.ArchiveRatio) {
			$payedRatio1 = [int]$project.ArchiveRatio.replace("%","")
			$arr = $project.ArchiveComment.split("`r`n")
			$distri1 = @{}
			$distriRatio1 = @{}
			$paysum1 = 0
			foreach ($estr in $arr) {
				$name, [int]$pay = ($estr -replace ("(.*?) *([0-9]+)",'$1 $2')).Split(" ")
				if (!$name -or !$pay) { continue; }
				$distri1.$name += $pay
				$paysum1 += $pay
			}
			if ($debug) {echo "    => 人数: $($distri1.Count), 总发放额: $paysum1($($($project.ArchiveRatio).replace("`r`n",", ")))"}
			foreach ($e1 in $distri1.GetEnumerator()|Sort Value) {
				$e1name = $e1.Name
				[double]$e1payRatio = $e1.Value/$paysum1
				if ($debug) {echo "        -> ${e1name}: $($e1.Value), $e1payRatio"}
				$distriRatio1.$e1name = $e1payRatio
				$edistriSum.$e1name += $e1.Value
			}
		}
		if ($debug) {echo "`n    [竣工发放]:$($project.CompletedRatio), 分配:($($($project.CompletedComment).replace("`r`n",", ")))"}
		if ($project.CompletedRatio) {
			$payedRatio2 = [int]$project.CompletedRatio.replace("%","")
			$arr = $project.CompletedComment.split("`r`n")
			$distri2 = @{}
			$paysum2 = 0
			foreach ($estr in $arr) {
				$name, [int]$pay = ($estr -replace ("(.*?)([0-9]+)",'$1 $2')).Split(" ")
				if (!$name -or !$pay) { continue; }
				$distri2.$name += $pay
				$paysum2 += $pay
			}
			if ($debug) {echo "    => 人数: $($distri2.Count), 总发放额: $paysum2($($project.CompletedRatio))"}
			foreach ($e2 in $distri2.GetEnumerator()|Sort Value) {
				$e2name = $e2.Name
				if ($debug) {echo "        -> ${e2name}: $($e2.Value), $($e2.Value/$paysum2)"}
				$edistriSum.$e2name += $e2.Value
			}
		}
		if ($debug) {echo "`n    [完成发放]:$($project.TOLL_finishRatio), 分配:($($project.TOLL_finishComment))"}
		if ($project.TOLL_finishRatio) {
			$payedRatio3 = [int]$project.TOLL_finishRatio.replace("%","")
			$arr = $project.CompletedComment.split("`r`n")
			$distri3 = @{}
			$paysum3 = 0
			foreach ($estr in $arr) {
				$name, [int]$pay = ($estr -replace ("(.*?)([0-9]+)",'$1 $2')).Split(" ")
				if (!$name -or !$pay) { continue; }
				$distri3.$name += $pay
				$paysum3 += $pay
			}
			if ($debug) {echo "    => 人数: $($distri3.Count), 总发放额: $paysum3($($project.TOLL_finishRatio))"}
			foreach ($e3 in $distri3.GetEnumerator()|Sort Value) {
				$e3name = $e3.Name
				if ($debug) {echo "        -> $($e3.Name): $($e3.Value), $($e3.Value/$paysum3)"}
				$edistriSum.$e3name += $e3.Value
			}
		}
		$payedRatio = $payedRatio1 + $payedRatio2 + $payedRatio3
		$ppayed = $paysum1 + $paysum2 + $paysum3
		if ($payedRatio -eq 0) {
			if ($debug) {echo "    Payed: ?%($ppayed), WARN: 发放比例为0，请检查表格数据是否正确!"}
		} elseif ($payedRatio -lt 100) {
			$payedRatioBalance = 100 - $payedRatio
			$payedBalance = $ppayed * $payedRatioBalance/$payedRatio
			if ($debug) {echo "    Payed: ${payedRatio}%($ppayed), Balance: ${payedRatioBalance}%($payedBalance)"}
			$payedBalanceSum += $payedBalance

			foreach ($e in $distri1.GetEnumerator()|Sort Value) {
				$ename = $e.Name
				$eRatio = $distriRatio1.$ename
				$edistriBalanceSum.$ename += [int]($payedBalance * $eRatio)
			}
		} else {
			% donothing;
		}
		$payedSum += $ppayed
		if ($debug) {echo "    PayedSum: ${payedSum}; $paysum1, $paysum2, $paysum3"}
	}

	if ($debug) {echo "`n`nTotal PayedSum: ${payedSum}, Balance: ${payedBalanceSum}"}

	echo "`n`nPayed for everyone:"
	[int]$_payedSUM = 0
	foreach ($e in $edistriSum.GetEnumerator()|Sort Value) {
		$name = $e.Name
		[int]$payedsum = $e.Value
		$_payedSUM += $payedsum
		echo "    -> ${name}:`t$("{0,15}" -f $payedsum)"
	}
	echo "    -> TOTAL:`t$("{0,15}" -f $_payedSUM)"

	echo "`n`nPay Balance for everyone:"
	[int]$_topaySUM = 0
	foreach ($e in $edistriBalanceSum.GetEnumerator()|Sort Value) {
		$ebname = $e.Name
		[int]$topaysum = $e.Value
		$_topaySUM += $topaysum
		echo "    -> ${ebname}:`t$("{0,15}" -f $topaysum)"
	}
	echo "    -> TOTAL:`t$("{0,15}" -f $_topaySUM)"
}
