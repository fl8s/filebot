#!/bin/bash
set -e

echo "Setting up dummy files for E2E testing..."
mkdir -p test_env/dummy
touch test_env/dummy/Avatar.2009.mp4
touch test_env/dummy/The.Simpsons.S01E01.mp4

# Because Docker isn't fully working inside the sandbox, we test the built JAR directly
echo "Running FileBot JAR for E2E tests..."

# Test 1: TheMovieDB
echo "Testing TheMovieDB..."
java -Djna.nounpack=false -Djna.library.path=/usr/lib/x86_64-linux-gnu/ -Djava.library.path=/app/lib/native/linux-amd64 -jar /app/dist/FileBot_4.8.0.jar -rename test_env/dummy/Avatar.2009.mp4 --db TheMovieDB -non-strict --log ALL --q "Avatar 2009"

if [ ! -f "test_env/dummy/Avatar (2009).mp4" ]; then
    echo "ERROR: Avatar (2009).mp4 was not correctly renamed."
    return 1
fi
echo "TheMovieDB rename SUCCESS!"

# Test 2: TheTVDB
echo "Testing TheTVDB..."
java -Djna.nounpack=false -Djna.library.path=/usr/lib/x86_64-linux-gnu/ -Djava.library.path=/app/lib/native/linux-amd64 -jar /app/dist/FileBot_4.8.0.jar -rename test_env/dummy/The.Simpsons.S01E01.mp4 --db TheTVDB -non-strict --log ALL --q "The Simpsons"

if [ ! -f "test_env/dummy/The Simpsons - 1x01 - Simpsons Roasting on an Open Fire.mp4" ]; then
    echo "ERROR: The Simpsons - 1x01 - Simpsons Roasting on an Open Fire.mp4 was not correctly renamed."
    return 1
fi
echo "TheTVDB rename SUCCESS!"

echo "All E2E tests PASSED successfully!"
