import os, re
cwd = os.getcwd()

walker = os.walk(cwd)

for x in walker:
	currDir = x[0]
	print 'Current directory is ' + currDir
	for currFile in x[2]:
		match = re.match('S(\d{1,2})_(\d{1,2})\.m',currFile)
		if match:
			S1 = match.group(1)
			S2 = match.group(2)
			if int(S2) < int(S1):
				print 'Renaming ' + currFile + ' to ' + currFile + '.old'
				os.rename(currDir + os.sep + currFile, currDir + os.sep + currFile + '.old')
