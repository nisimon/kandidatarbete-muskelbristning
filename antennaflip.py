import os, re,shutil
cwd = os.getcwd()

walker = os.walk(cwd)

flips = {'1':'5','2':'4','6':'9','7':'8','10':'14','11':'13',
		 '5':'1','4':'2','9':'6','8':'7','14':'10','13':'11'}

for x in walker:
	srcDir = x[0]
	relPath = os.path.relpath(x[0],cwd)
	if relPath == '.':
		relPath = ''
	dstDir = os.path.join(cwd, 'flipped', relPath)
	if not os.path.exists(dstDir):
		os.makedirs(dstDir)
	print('Current directory is ' + srcDir)
	
	for currFile in x[2]:
		match = re.match('S(\d{1,2})_(\d{1,2})\.m$',currFile)
		if match:
			S1 = match.group(1)
			S2 = match.group(2)

			if S1 in flips:
				S1_flipped = flips[S1]
			else:
				S1_flipped = S1

			if S2 in flips:
				S2_flipped = flips[S2]
			else:
				S2_flipped = S2

			if int(S1_flipped) > int(S2_flipped):
				S1_flipped, S2_flipped = S2_flipped, S1_flipped

			newName = 'S' + S1_flipped + '_' + S2_flipped + '.m'
			src = os.path.join(srcDir,currFile)
			dest = os.path.join(dstDir, newName)
			print('Copying ' + src + ' to ' + dest)
			shutil.copy(src, dest)
