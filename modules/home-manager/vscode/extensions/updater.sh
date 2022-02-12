#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq unzip
set -euxo pipefail
shopt -s nullglob

# Helper to just fail with a message and non-zero exit code.
function fail() {
    echo "$1" >&2
    exit 1
}

# Helper to clean up after ourselves if we're killed by SIGINT.
function clean_up() {
    TDIR="${TMPDIR:-/tmp}"
    echo "Script killed, cleaning up tmpdirs: $TDIR/vscode_exts_*" >&2
    rm -Rf "$TDIR/vscode_exts_*"
}

function get_vsixpkg() {
    N="$1.$2"

    # Create a tempdir for the extension download.
    EXTTMP=$(mktemp -d -t vscode_exts_XXXXXXXX)

    URL="https://$1.gallery.vsassets.io/_apis/public/gallery/publisher/$1/extension/$2/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

    # Quietly but delicately curl down the file, blowing up at the first sign of trouble.
    curl --silent --show-error --fail -X GET -o "$EXTTMP/$N.zip" "$URL"
    # Unpack the file we need to stdout then pull out the version
    VER=$(jq -r '.version' <(unzip -qc "$EXTTMP/$N.zip" "extension/package.json"))
    # Calculate the SHA
    SHA=$(nix-hash --flat --base32 --type sha256 "$EXTTMP/$N.zip")

    # Clean up.
    rm -Rf "$EXTTMP"
    # I don't like 'rm -Rf' lurking in my scripts but this seems appropriate.

    cat <<-EOF
  {
    name = "$2";
    publisher = "$1";
    version = "$VER";
    sha256 = "$SHA";
  }
EOF
}

# Retrieve nixpkgs from environment
## Read the environment variable NIX_PATH into an array split by :
IFS=':' read -r -a nix_path <<< "$NIX_PATH"
## Get the value of the element which defines nixpkgs
for i in "${!nix_path[@]}"; do
    if [[ "${nix_path[i]}" == *"nixpkgs="* ]]; then
        nixpkgs_path="${nix_path[i]}"
        break # exit on first match
    fi
done
## Remove nixpkgs= from nixpkgs_path
nixpkgs_path="${nixpkgs_path#*nixpkgs=}"

mydir="$(dirname ${BASH_SOURCE[0]})"

# See if we can find our `code` binary somewhere.
if [ $# -ne 0 ]; then
    CODE=$1
else
    CODE=$(command -v code || command -v codium)
fi

if [ -z "$CODE" ]; then
    # Not much point continuing.
    fail "VSCode executable not found"
fi

# Try to be a good citizen and clean up after ourselves if we're killed.
trap clean_up SIGINT

# Begin the printing of the nix expression that will house the list of extensions.
printf '{ extensions = [\n' > "$mydir/deps.nix"

# Note that we are only looking to update extensions that are already installed.
for i in $($CODE --list-extensions)
do
    OWNER=$(echo "$i" | cut -d. -f1)
    EXT=$(echo "$i" | cut -d. -f2)

    get_vsixpkg "$OWNER" "$EXT" >> "$mydir/deps.nix"
done
# Close off the nix expression.
printf '];\n}' >> "$mydir/deps.nix"
