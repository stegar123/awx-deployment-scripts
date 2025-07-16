#!/bin/bash
set -e

echo "🔄 Starting AWX Operator repository clone..."

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed. Please install git first."
    exit 1
fi

# Remove existing directory if it exists
if [ -d "awx-operator" ]; then
    echo "⚠️  Removing existing awx-operator directory..."
    rm -rf awx-operator
fi

# Clone the repository
echo "📥 Cloning AWX Operator repository..."
git clone https://github.com/ansible/awx-operator.git

# Navigate to the directory and checkout specific version
cd awx-operator
echo "🔄 Checking out version 2.19.1..."
git checkout 2.19.1

# Return to original directory
cd -

echo "✅ AWX Operator repository cloned successfully!"
echo "📁 Location: $(pwd)/awx-operator"