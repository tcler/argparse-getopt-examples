[CmdletBinding()]
param (
	[int]$headRowsCount = 4,
	[int]$nameColumnIndex = 5,

	[Parameter(Position = 0, ValueFromRemainingArguments = $true)]
	[string]$oargs
)

#±äÁ¿ÉùÃ÷
$OrigExcelFile = Resolve-Path @($oargs)[0]

echo "{info} open $OrigExcelFile ..."
$Excel = New-Object -ComObject Excel.Application
$Excel.DisplayAlerts = $false;
$wb = $Excel.Workbooks.Open($OrigExcelFile)
$ws = @($wb.Worksheets)[0]

$rowcnt = ($ws.UsedRange.Rows).count
$colcnt = ($ws.UsedRange.Colums).count

echo "{info} create template worksheet ..."
$ws.Copy($wb.Worksheets.Item(2))
$wstmp = $wb.Worksheets.Item(2)
$wstmp.Name = "tmpsheet"

$tmprowcnt = ($wstmp.UsedRange.Rows).count
while ($tmprowcnt -gt $headRowsCount) {
	for ($i = $headRowsCount; $i -lt $tmprowcnt; $i++) {
		[void]$wstmp.Cells.Item($i, 1).EntireRow.Delete()
	}
	$tmprowcnt = ($wstmp.UsedRange.Rows).count
	echo "{debug} tempsheet row count: $tmprowcnt"
}
echo "{info} origsheet row count: $rowcnt"
echo "{info} tempsheet row count: $tmprowcnt"

$payrollFolder = "$pwd\Payroll-List"
New-Item -Path $payrollFolder -ItemType Directory -ErrorAction Ignore >$null

$dstRowIdx = $headRowsCount
for ($i = $headRowsCount; $i -lt $rowcnt; $i++) {
	$name = $ws.Cells.Item($i, $nameColumnIndex).text 
	if ($name -eq "") { continue }
	$newPath = "$payrollFolder\Pay-$name.xlsx"
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

	[void]$workbook.Worksheets.Item(2).Delete()
	$workbook.SaveAs($newPath)
}
[void]$wstmp.Delete()
$Excel.Workbooks.Close()

$Excel.Quit()
