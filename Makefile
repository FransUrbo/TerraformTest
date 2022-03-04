all: s3-cleanup.zip _src/dependencies.txt _src/handler.py

s3-cleanup.zip: _src/build/distributions/s3-cleanup-SNAPSHOT.zip
	(cd _src; ./build.sh -p)
	ln -sf _src/build/distributions/s3-cleanup-SNAPSHOT.zip s3-cleanup.zip
