#!/bin/bash
# Setup script for package review system

set -e

echo "🔧 Package Review System Setup"
echo "=============================="
echo

# Check if we're in the pkgreview directory
if [ ! -f "scripts/process_templates.py" ]; then
    echo "Error: Please run this script from the pkgreview root directory"
    exit 1
fi

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    exit 1
fi

# Create config from template if it doesn't exist
if [ ! -f "config.yml" ]; then
    echo "Creating config.yml from template..."
    cp templates/config/config.yml.template config.yml
    echo "✅ config.yml created"
    echo
    echo "Please edit config.yml with your organization's settings,"
    echo "then run this script again to generate the customized files."
    exit 0
fi

# Run template processor
echo "Processing templates with your configuration..."
python3 scripts/process_templates.py

echo
echo "✅ Setup complete!"
echo
echo "Next steps:"
echo "1. Copy commands to Claude: cp commands/*.md ~/.claude/commands/"
echo "2. Start reviewing: /review-package [package-name]"