import os, re
cwd = os.getcwd()

walker = os.walk(cwd)

for x in walker:
	currDir = x[0]
	print 'Current directory is ' + currDir
	for currFile in x[2]:
		match = re.match('(S\d{1,2}_\d{1,2}\.m)\.old',currFile)
		if match:
			oldName = match.group(1)
			print 'Renaming ' + currFile + ' to ' + oldName
			os.rename(currDir + os.sep + currFile, currDir + os.sep + oldName)
