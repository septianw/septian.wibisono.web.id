NAME = "septian.wibisono.web.id"
MYSQLPASS = "dengdong"
DISKSIZE = "10M"
DBDATA = $(NAME)"-mysql-data"

build:
	cp dev.yml docker-compose.yml
	docker create --name $(NAME)-mysql-data -v /var/lib/mysql mariadb > mysqldata
	fallocate -l $(DISKSIZE) $(NAME).img
#	dd if=/dev/zero of=$(NAME).img bs=4096 count=$(DISKSIZE)
	./format.sh disk  $(NAME).img
	mkdir space
	mount $(NAME).img space
	./format.sh compose $(DBDATA)
	./format.sh afterbuildhook
	docker-compose up -d 
	./format.sh afterdeployhook

destroy:
	docker-compose stop
	docker-compose rm --force
	cat mysqldata | xargs --no-run-if-empty docker rm 
	umount space
	rm -rf $(NAME).img space mysqldata docker-compose.yml
	rm /etc/nginx/sites-available/$(NAME).conf
	rm /etc/nginx/sites-enabled/$(NAME).conf

bangun:
	echo $(PW)
	echo $(DBDATA)
