FROM elasticsearch:7.9.2

#Kernel settings
RUN ulimit -n 65536

# Copy keystore
COPY config/elasticsearch.keystore /usr/share/elasticsearch/config/
# Copy config
COPY config/elasticsearch.yml /usr/share/elasticsearch/config/
# Copy node certtificate
COPY certs/cert.p12 /usr/share/elasticsearch/config/certs/
# Copy http certtificate
COPY certs/http.p12 /usr/share/elasticsearch/config/certs/

#Fix permissions - Allow data to be written
RUN chown -R 1000:1000 /usr/share/elasticsearch/data
RUN chown -R 1000:1000 /usr/share/elasticsearch/config/certs
RUN chown -R 1000:1000 /usr/share/elasticsearch/config/elasticsearch.keystore
RUN chown -R 1000:1000 /usr/share/elasticsearch/config/elasticsearch.yml

#Install fonts for dataformat xlsx export
RUN yum install -y freetype fontconfig dejavu-sans-fonts

#Install plugins
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch org.codelibs:elasticsearch-dataformat:7.9.0 
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch repository-s3

