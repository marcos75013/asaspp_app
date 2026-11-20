#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  git clone --filter=blob:none --depth 1 --branch 3.41.0 \
    https://github.com/flutter/flutter.git /tmp/multiasso-flutter
  export PATH="/tmp/multiasso-flutter/bin:$PATH"
fi

flutter pub get
flutter build web --release \
  --dart-define=API_BASE_URL=https://multi-asso-api.onrender.com
