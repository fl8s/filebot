FROM ubuntu:20.04

# Prevent tzdata from prompting for input
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies (build + runtime since docker overlay seems to fail on this runner)
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk-headless \
    ant \
    ivy \
    wget \
    git \
    openjfx \
    libopenjfx-java \
    libopenjfx-jni \
    openjfx-source \
    libmediainfo-dev \
    libchromaprint-tools \
    && rm -rf /var/lib/apt/lists/* || true

# Fix ivy.jar location for ant
RUN ln -s /usr/share/java/ivy.jar /usr/share/ant/lib/ivy.jar || true

# Set up working directory
WORKDIR /app

# Copy the source code
COPY . .

# Build the fatjar
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV CLASSPATH="/usr/share/openjfx/lib/*"
RUN ant resolve && ant fatjar

# Set up entrypoint and environment for running
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV JNA_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu/"
ENV JAVA_LIBRARY_PATH="/app/lib/native/linux-amd64"

ENTRYPOINT ["java", "-Djna.nounpack=false", "-Djna.library.path=/usr/lib/x86_64-linux-gnu/", "-Djava.library.path=/app/lib/native/linux-amd64", "-jar", "/app/dist/FileBot_4.8.0.jar"]
CMD ["-help"]
