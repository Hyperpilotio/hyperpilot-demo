FROM    hyperpilot/benchmark-controller:latest
	# Extends benchmark-controller template image
ADD     parser.js extension-lib/parser.js
ADD     config.json config/config.json
ADD 	mongo-perf ./mongo-perf
	# Install Python packages
RUN	apt-get update -y	
RUN 	apt-get install python-dev -y
RUN 	apt-get install python-pip -y
RUN 	pip install -r mongo-perf/requirements.txt
	# Install Mongo
RUN 	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN 	echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN 	apt-get update
RUN 	apt-get install -y mongodb-org

