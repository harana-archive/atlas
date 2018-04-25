ENV   ATLAS_REPO                    https://github.com/apache/atlas \
      ATLAS_TAG                     release-1.0.0-alpha-rc2 \
      MAVEN_OPTS                    "-Xmx2048m -XX:MaxPermSize=512m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

ENV   DYNAMODB_REPO                 https://github.com/awslabs/dynamodb-janusgraph-storage-backend \
      DYNAMODB_TAG                  jg0.2.0-1.2.0 \
      SHADE_PLUGIN                  <profile><id>shade</id><build><plugins> \
                                    <plugin><groupId>org.apache.maven.plugins</groupId><artifactId>maven-shade-plugin</artifactId> \
                                    <version>3.1.0</version><executions><execution><phase>package</phase><goals><goal>shade</goal></goals> \
                                    <configuration><relocations><relocation><pattern>com.google</pattern> \
                                    <shadedPattern>com.shaded.google</shadedPattern></relocation></relocations> \
                                    <artifactSet><includes><include>com.google.guava:*</include></includes></artifactSet> \
                                    </configuration></execution></executions></plugin></plugins></build></profile>

ENV   ATLAS_HOME	            /opt/atlas \
      ATLAS_CLIENT_HEAP	            1024MB

FROM                                maven:3.5.3-jdk-8 AS builder-atlas

RUN                                 git clone -b ${ATLAS_TAG} --single-branch --depth 1 ${ATLAS_REPO} atlas && \
                                    cd atlas && \
                                    mvn clean package -Pdist -DskipTests -Dmaven.artifact.threads=20 && \
                                    mv distro/target/apache-atlas-*-bin.tar.gz /apache-atlas.tar.gz

FROM                                maven:3.5.3-jdk-8 AS builder-dynamodb-janusgraph

RUN                                 git clone -b ${TAG} --single-branch --depth 1 ${REPO} dynamodb-janusgraph && \
                                    cd dynamodb-janusgraph && \
                                    sed -i -e "s#<profiles>#<profiles>${SHADE_PLUGIN}#" pom.xml && \
                                    mvn clean package -Pshade -DskipTests -Dmaven.artifact.threads=20 && \
                                    mv target/dynamodb-janusgraph-storage-backend-1.2.0.jar / && \
                                    rm target/dependencies/guava*.jar && \
                                    mv target/dependencies/*.jar /

FROM                                openjdk:8-jdk-alpine

COPY                                --from=builder-atlas /apache-atlas.tar.gz /apache-atlas.tar.gz

RUN                                 apk --no-cache add tar python bash && \
                                    mkdir -p ${ATLAS_HOME} && \
                                    tar xvz -C ${ATLAS_HOME} -f /apache-atlas.tar.gz --strip-component=1 && \
                                    rm -rf /apache-atlas.tar.gz && \
                                    mkdir -p ${ATLAS_HOME}/libext

COPY                                --from=builder-dynamodb-janusgraph /*.jar ${ATLAS_HOME}/libext/
