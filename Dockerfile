FROM ubuntu:14.04.3

MAINTAINER Michael Seaton <mseaton@pih.org>

RUN apt-get update
RUN apt-get install -y openssh-server
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 irb1.9.1 ri1.9.1 build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

RUN mkdir /etc/puppet-decrypt
RUN ssh-keygen -N testmeout -f /etc/puppet-decrypt/encryptor_secret_key

RUN gem install bundler --no-ri --no-rdoc

ADD .rvmrc /
ADD Gemfile /

RUN bundle

ADD Puppetfile /
RUN apt-get install -y git

RUN librarian-puppet install

ADD . /etc/puppet

WORKDIR /etc/puppet

RUN echo "modulepath = /etc/puppet/modules:/etc/puppet/mirebalais-modules" > /etc/puppet/puppet.conf
RUN echo "environment = local" >> /etc/puppet/puppet.conf

CMD /bin/bash