FROM centos:6
MAINTAINER Punko <Punkoivan@yandex.ru>
RUN yum update -y
RUN yum install -y httpd php php-mysql
CMD [ "service", "httpd", "start "]
EXPOSE 80
ENTRYPOINT [ "/usr/sbin/httpd", "-DFOREGROUND" ]
