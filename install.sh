#!/bin/bash

# Function to print error messages
error() {
    echo "$1" >&2
    exit 1
}

# Check for prerequisites
command -v git >/dev/null 2>&1 || error "git is required but not installed. Aborting."
command -v python3 >/dev/null 2>&1 || error "python3 is required but not installed. Aborting."
command -v pip3 >/dev/null 2>&1 || error "pip3 is required but not installed. Aborting."

# Variables
REPO_URL="https://github.com/Amanuel-Ayal3w/metta-prebuilt-binary.git"
INSTALL_DIR="$HOME/metta-bin"
VENV_DIR="$INSTALL_DIR/venv"
DESTINATION_PATH="/usr/local/bin/metta"
WRAPPER_PATH="/usr/local/bin/metta-run"

# Step 1: Clone the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "The repository already exists. Skipping cloning."
else
    echo "Cloning the repository..."
    git clone $REPO_URL $INSTALL_DIR || error "Failed to clone repository."
fi

cd $INSTALL_DIR || error "Failed to enter the repository directory."

# Step 2: Set up Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv $VENV_DIR || error "Failed to create Python virtual environment."
source $VENV_DIR/bin/activate || error "Failed to activate Python virtual environment."

# Step 3: Install Python dependencies
if [ -f "./requirements.txt" ]; then
    echo "Installing Python dependencies..."
    pip install -r requirements.txt || error "Failed to install Python dependencies."
else
    echo "No requirements.txt found"
    error "Failed to install Python dependencies."
fi

# Step 4: Detect Metta binary automatically
echo "Looking for built Metta binaries..."
METTA_BINARY=$(find "$INSTALL_DIR" -type f -name "metta" | head -n 1)

if [ -z "$METTA_BINARY" ]; then
    error "Metta binary not found. Did you include it in your fork?"
fi

echo "Found Metta binary at: $METTA_BINARY"

echo "Copying Metta binary to $DESTINATION_PATH..."
sudo cp "$METTA_BINARY" "$DESTINATION_PATH" || error "Failed to move metta binary."

sudo chmod +x "$DESTINATION_PATH" || error "Failed to make the metta binary executable."

echo "Metta installed successfully!"

# Step 5: Install wrapper binary if available
WRAPPER_BINARY=$(find "$INSTALL_DIR" -type f -name "metta-run" | head -n 1)

if [ -n "$WRAPPER_BINARY" ]; then
    echo "Found wrapper binary: $WRAPPER_BINARY"
    echo "Installing wrapper binary to $WRAPPER_PATH..."
    sudo cp "$WRAPPER_BINARY" "$WRAPPER_PATH" || error "Failed to install wrapper binary."
    sudo chmod +x "$WRAPPER_PATH" || error "Failed to make wrapper binary executable."
    echo "metta-run installed successfully!"
else
    echo "No wrapper binary found. Skipping wrapper installation."
fi

echo "Installation complete!"
echo "Run 'metta' from any path."
echo "Or run 'metta-run' to use automatic Python environment activation (if available)."
