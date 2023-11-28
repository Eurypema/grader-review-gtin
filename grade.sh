#!/bin/bash

# Get the absolute path to the directory containing the script
SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Define the test and required file names
TEST_FILE="TestListExamples.java"
REQUIRED_FILE="ListExamples.java"

# Correct paths for JAR files
CPATH="$SCRIPT_DIR/lib/hamcrest-core-1.3.jar:$SCRIPT_DIR/lib/junit-4.13.2.jar"

# Clean up and create necessary directories
rm -rf student-submission grading-area
mkdir -p grading-area student-submission || exit 1

# Clone the student's submission repository
if ! git clone "$1" student-submission; then
    echo "Error: Failed to clone the repository."
    exit 1
fi

# Verify the required Java file exists
if [ ! -f "student-submission/$REQUIRED_FILE" ]; then
    echo "Error: $REQUIRED_FILE does not exist in the submission. Please submit the correct Java file."
    exit 1
fi

# Move the required files to the grading-area
cp "student-submission/$REQUIRED_FILE" "grading-area/$REQUIRED_FILE"
cp "$TEST_FILE" "grading-area/$TEST_FILE"

# Change to the grading-area directory
cd grading-area || exit 1

# Compile the Java files
javac -cp "$CPATH" "$TEST_FILE" "$REQUIRED_FILE" || exit 1

# Run the tests using JUnit
test_result=$(java -cp "$CPATH" org.junit.runner.JUnitCore "$(basename "$TEST_FILE" .java)")
test_exit_code=$?

# Check test results
if [ $test_exit_code -ne 0 ]; then
    echo "Some tests failed. Please review the test results below:"
    echo "$test_result"
else
    number_of_tests=$(echo "$test_result" | grep -o "Tests run: [0-9]*" | grep -o "[0-9]*")
    echo "All tests passed ($number_of_tests/$(($number_of_tests)))! Great job!"
fi
