FROM                                anapsix/alpine-java:8_jdk_unlimited

ENV   ATLAS_CLIENT_HEAP                   1024MB \
      ATLAS_MIN_THREADS                   10 \
      ATLAS_MAX_THREADS                   100 \
      ATLAS_METRICS_GRAPHITE_HOSTNAME     localhost \      
      ATLAS_METRICS_GRAPHITE_PORT         localhost \    
      ATLAS_METRICS_GRAPHITE_PREFIX       atlas_logs \                 
      ATLAS_LOGS_ELASTICSEARCH_HOSTNAME   localhost \ 
      ATLAS_LOGS_ELASTICSEARCH_PORT       9200 \      
      ATLAS_LOGS_ELASTICSEARCH_PREFIX     atlas_logs \               
      ATLAS_THREAD_QUEUE_SIZE             100 \
      AWS_CREDENTIALS_PROVIDER            com.amazonaws.auth.BasicAWSCredentials \
      AWS_REGION                          ap-southeast-2 \
      DYNAMODB_PREFIX                     atlas \
      DYNAMODB_ES_CAPACITY_READ           2 \
      DYNAMODB_ES_CAPACITY_WRITE          2 \
      DYNAMODB_ES_READ_RATE               2 \
      DYNAMODB_ES_WRITE_RATE              2 \
      DYNAMODB_GI_CAPACITY_READ           2 \
      DYNAMODB_GI_CAPACITY_WRITE          2 \
      DYNAMODB_GI_READ_RATE               2 \
      DYNAMODB_GI_WRITE_RATE              2 \
      ELASTICSEARCH_HOSTNAME              localhost  \
      ELASTICSEARCH_PORT                  9200 \
      ELASTICSEARCH_PREFIX                atlas

COPY                                      /atlas.tgz /atlas.tgz

RUN                                       mkdir -p /opt/atlas && tar xz -C /opt/atlas -f /atlas.tgz && \
                                          rm -rf /atlas.tgz

RUN                                       cd /opt/atlas/webapp && mkdir temp && mv atlas.war temp/atlas.jar && cd temp && \
                                          jar -vxf atlas.jar && rm atlas.jar          

RUN                                                                                 

EXPOSE                                    21000

CMD                                       ["/bin/bash"]
