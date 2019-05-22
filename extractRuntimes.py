import zipfile
zf = zipfile.ZipFile(r'C:\vc_runtimes.zip')
zf.extractall(r'C:\vc_runtimes')
zf.close()