#!/bin/bash
set -e

# Change to the directory where the script is located to ensure paths are relative
cd "$(dirname "$0")"

echo "Setting up realistic directories for End-to-End usage tests..."
rm -rf test_env/input test_env/output test_env/amc.log
mkdir -p test_env/input
mkdir -p test_env/output

# Create some messy files simulating a real-world Downloads folder
touch test_env/input/The.Matrix.1999.1080p.mkv
touch test_env/input/Breaking.Bad.S01E01.720p.HDTV.x264.mp4

# Check for the jar file
JAR_FILE=$(ls dist/FileBot_*.jar 2>/dev/null | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "ERROR: Could not find FileBot JAR in dist/"
    exit 1
fi

echo "Running FileBot JAR using the AMC script..."

# We use the AMC (Automated Media Center) script which is what most people use for automation.
# Note: In a test environment without license, amc might be restricted or display warnings.
# Let's use standard -rename if AMC is too restrictive, or just normal CLI args.
# The previous e2e used just `-rename` and `--db`. We will simulate a more robust usage:
# sorting movies and tv shows into structured directories.

# Actually amc requires a license in 4.8.x typically, but let's test a complex format instead of amc script
# Since amc script failed in earlier local test due to no license/donation nag or unsupported without explicit donation.
# The user wants "something that simulates actual usage of this software, successfully running".
# Standard complex rename into a structured directory is very common.

# Let's run a complex rename command that sorts Movies and TV Shows.
echo "Organizing Movie..."
java -Djna.nounpack=false -Djna.library.path=/usr/lib/x86_64-linux-gnu/ -Djava.library.path=lib/native/linux-amd64 -jar "$JAR_FILE" -rename test_env/input/The.Matrix.1999.1080p.mkv --db TheMovieDB -non-strict --format "../output/Movies/{n} ({y})/{n} ({y})" --log ALL --q "The Matrix 1999"

echo "Organizing TV Show..."
java -Djna.nounpack=false -Djna.library.path=/usr/lib/x86_64-linux-gnu/ -Djava.library.path=lib/native/linux-amd64 -jar "$JAR_FILE" -rename test_env/input/Breaking.Bad.S01E01.720p.HDTV.x264.mp4 --db TheTVDB -non-strict --format "../output/TV Shows/{n}/Season {s}/{n} - {s00e00} - {t}" --log ALL --q "Breaking Bad"

# Assertions
if [ ! -f "test_env/output/Movies/The Matrix (1999)/The Matrix (1999).mkv" ]; then
    echo "ERROR: The Matrix was not correctly organized."
    /bin/false
fi
echo "Movie organization SUCCESS!"

if [ ! -f "test_env/output/TV Shows/Breaking Bad/Season 1/Breaking Bad - S01E01 - Pilot.mp4" ]; then
    echo "ERROR: Breaking Bad was not correctly organized."
    /bin/false
fi
echo "TV Show organization SUCCESS!"

echo "All Real World Usage E2E tests PASSED successfully!"
