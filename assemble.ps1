$filename=$args[0]
$outname=$args[1]

nasm $filename -o $outname 
$varadd = $PSScriptRoot+'\'+$outname
echo $varadd
dosbox $varadd