FROM centos:6.6
MAINTAINER levkov

RUN rm -f /etc/localtime && ln -sf /usr/share/zoneinfo/UTC /etc/localtime
RUN printf "[mt-yum]\nname = mt-yum\nbaseurl = http://mt-yum.s3.amazonaws.com\ngpgcheck=0" > /etc/yum.repos.d/mt-yum.repo
RUN yum update -y
RUN yum install -y wget
RUN wget dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -ivh epel-release-6-8.noarch.rpm
RUN yum install -y jdk1.8.0_25 python-pip python-meld3 mc htop iftop telnet openssh-server openssh-clients
RUN pip install supervisor boto

RUN groupadd -r ec2-user && useradd -r -g ec2-user ec2-user

RUN echo 'root:ContaineR' | chpasswd

RUN rm -f /etc/ssh/ssh_host_ecdsa_key /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config

COPY conf/supervisord.conf /etc/supervisord.conf
EXPOSE 9001 22
CMD ["/usr/bin/supervisord"]
