[CmdletBinding()]
param (
	[int]$headRowsCount = 3,
	[int]$nameColumnIndex = 5,

	[Parameter(Position = 0, ValueFromRemainingArguments = $true)]
	[string]$oargs
)

$existingExcel = @()
Get-Process Excel -ErrorAction Ignore | % { $existingExcel += $_.ID }
echo "{debug} existingExcel: {$existingExcel}"
function Stop-Excel
{
	Get-process EXCEL | % { if ($_.ID -notmatch $existingExcel) {echo "{debug} stop $($_.ID)"; Stop-Process -ID $_.ID} }
}

#变量声明
$OrigExcelFile = Resolve-Path @($oargs)[0]
$firstDataRowIndex = $headRowsCount + 1
$timeColumnIndex = 1

echo "{info} open $OrigExcelFile ..."
$Excel = New-Object -ComObject Excel.Application
$Excel.DisplayAlerts = $false;
$wb = $Excel.Workbooks.Open($OrigExcelFile)
$ws = @($wb.Worksheets)[0]
echo "{debug} $($ws.Cells.Item(1,5).text)"
echo "{debug} $($ws.Cells.Item(2,5).text)"
echo "{debug} $($ws.Cells.Item(3,5).text)"

$rowcnt = ($ws.UsedRange.Rows).count
$colcnt = ($ws.UsedRange.Colums).count

echo "{info} create template worksheet ..."
$ws.Copy($wb.Worksheets.Item(1))
$wstmp = $wb.Worksheets.Item(1)
$wstmp.Name = "tmpsheet"

$tmprowcnt = ($wstmp.UsedRange.Rows).count
while ($tmprowcnt -gt $firstDataRowIndex) {
	for ($i = $firstDataRowIndex; $i -lt $tmprowcnt; $i++) {
		[void]$wstmp.Cells.Item($i, 1).EntireRow.Delete()
	}
	$tmprowcnt = ($wstmp.UsedRange.Rows).count
	echo "{debug} tempsheet row count: $tmprowcnt"
}
echo "{info} origsheet row count: $rowcnt"
echo "{info} tempsheet row count: $tmprowcnt"

$time = $ws.Cells.Item($firstDataRowIndex, $timeColumnIndex).text 
$payrollFolder = "$pwd\payroll-list-$time"
New-Item -Path $payrollFolder -ItemType Directory -ErrorAction Ignore >$null

$dstRowIdx = $firstDataRowIndex
for ($i = $firstDataRowIndex; $i -le $rowcnt; $i++) {
	$time = $ws.Cells.Item($i, $timeColumnIndex).text 
	$name = $ws.Cells.Item($i, $nameColumnIndex).text 
	if ($name -eq "") { continue }
	$newPath = "$payrollFolder\${time}-工资单 $name.xlsx"
	echo "{info} generate $newPath"
	$workbook = $Excel.Workbooks.Add()
	$worksheet = $workbook.Worksheets.Item(1)
	$wstmp.Copy($worksheet)
	$worksheet = $workbook.Worksheets.Item(1)
	$worksheet.Name = "Pay $name"

	$ws.activate()
	$srcRange = $ws.Rows.Item($i)
	[void]$srcRange.copy()

	$worksheet.activate()
	$dstRange = $worksheet.Rows.Item($dstRowIdx)
	$worksheet.paste($dstRange)

	$selectRange = $worksheet.Cells.Item($dstRowIdx, 5)
	[void]$selectRange.Select()

	#[void]$workbook.Worksheets.Item(2).Delete()
	$workbook.SaveAs($newPath)
}
[void]$wstmp.Delete()
$Excel.Workbooks.Close()

$Excel.Quit()
Stop-Excel
