FROM                                maven:3.5.3-jdk-8 AS builder-atlas

ENV   ATLAS_REPO                    https://github.com/apache/atlas
ENV   ATLAS_TAG                     release-1.0.0-alpha-rc2
ENV   ATLAS_HOME	                  /opt/atlas
ENV   ATLAS_CLIENT_HEAP	            1024MB
ENV   ATLAS_MIN_THREADS             10
ENV   ATLAS_MAX_THREADS             100
ENV   ATLAS_THREAD_QUEUE_SIZE       100
ENV   MAVEN_OPTS                    "-Xmx2048m -XX:MaxPermSize=512m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

RUN                                 git clone -b ${ATLAS_TAG} --single-branch --depth 1 https://github.com/apache/atlas atlas && \
                                    cd atlas && \
                                    mvn clean package -Pdist -DskipTests -Dmaven.artifact.threads=20 && \
                                    mv distro/target/apache-atlas-*-bin.tar.gz /apache-atlas.tar.gz

FROM                                maven:3.5.3-jdk-8 AS builder-dynamodb-janusgraph

ENV   SHADE_PLUGIN                  <profile><id>shade</id><build><plugins> \
                                    <plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-shade-plugin</artifactId> \
                                    <version>3.1.0</version><executions><execution><phase>package</phase><goals><goal>shade</goal></goals> \
                                    <configuration><relocations><relocation><pattern>com.google</pattern> \
                                    <shadedPattern>com.shaded.google</shadedPattern></relocation></relocations> \
                                    <artifactSet><includes><include>com.google.guava:*</include></includes></artifactSet> \
                                    </configuration></execution></executions></plugin></plugins></build></profile>

RUN                                 git clone -b ${DYNAMODB_TAG} --single-branch --depth 1 https://github.com/awslabs/dynamodb-janusgraph-storage-backend dynamodb-janusgraph && \
                                    cd dynamodb-janusgraph && \
                                    sed -i -e "s#<profiles>#<profiles>${SHADE_PLUGIN}#" pom.xml && \
                                    mvn clean package -Pshade -DskipTests -Dmaven.artifact.threads=20 && \
                                    mv target/dynamodb-janusgraph-storage-backend*.jar / && \
                                    rm target/dependencies/guava*.jar && \
                                    mv target/dependencies/*.jar /

FROM                                anapsix/alpine-java:8_jdk_unlimited

ENV   ATLAS_HOME	                  /opt/atlas

COPY                                --from=builder-atlas /apache-atlas.tar.gz /apache-atlas.tar.gz

RUN                                 apk --no-cache add tar && \
                                    mkdir -p /opt/atlas && \
                                    tar xz -C /opt/atlas -f /apache-atlas.tar.gz --strip-component=1 && \
                                    rm -rf /apache-atlas.tar.gz && \
                                    mkdir -p /opt/atlas/libext

COPY                                --from=builder-dynamodb-janusgraph /*.jar /opt/atlas/libext/
