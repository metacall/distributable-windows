# This script is used for patching the configuration of metacall with relative paths
param(
	[string]$loc
)

# Use Unix path
$loc = $loc -replace '\\', '/'

# Get all JSON files in the configurations directory
$files = Get-ChildItem -Path "$loc/configurations" -Filter *.json

# Replace the global.json file, and anything that is pointing to configurations folder
foreach ($file in $files) {
	# Read file as text
	$content = Get-Content $file.FullName -Raw

	# Replace "%loc%/./configurations/" with "./"
	$pattern = [regex]::Escape("$loc/./configurations/")
	$content = $content -replace $pattern, "./"

	# Write the modified content back to the file
	Set-Content $file.FullName $content
}

# Replace any other file pointing outside of configurations folder
foreach ($file in $files) {
	# Read file as text
	$content = Get-Content $file.FullName -Raw

	# Replace "%loc%/" with "../"
	$pattern = [regex]::Escape("$loc/")
	$content = $content -replace $pattern, "../"

	# Debug the files
	Write-Host $content

	# Write the modified content back to the file
	Set-Content $file.FullName $content
}
