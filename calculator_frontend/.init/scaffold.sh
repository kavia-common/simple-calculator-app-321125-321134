#!/usr/bin/env bash
set -euo pipefail
# Idempotent SwiftPM calculator scaffold for container workspace
WORKSPACE="/home/kavia/workspace/code-generation/simple-calculator-app-321125-321134/calculator_frontend"
mkdir -p "$WORKSPACE" && cd "$WORKSPACE"
PKG_FILE="$WORKSPACE/Package.swift"
# detect iOS imports (exclude build dir)
if grep -R --line-number -E "import\s+(UIKit|AppKit|SwiftUI)" --exclude-dir=".build" "$WORKSPACE" 2>/dev/null; then
  NEED_STUBS=1
else
  NEED_STUBS=0
fi
# backup existing Package.swift if present
if [ -f "$PKG_FILE" ]; then
  [ -f "$PKG_FILE.bak" ] || cp -n "$PKG_FILE" "$PKG_FILE.bak" || true
else
  cat > "$PKG_FILE" <<'EOF'
// swift-tools-version:5.9
import PackageDescription
let package = Package(
  name: "CalculatorPackage",
  products: [ .library(name: "Calculator", targets: ["Calculator"]) ],
  targets: [
    .target(name: "Calculator", dependencies: [
EOF
  if [ "$NEED_STUBS" -eq 1 ]; then cat >> "$PKG_FILE" <<'EOF'
      "PlatformStubs",
EOF
  fi
  cat >> "$PKG_FILE" <<'EOF'
    ]),
EOF
  if [ "$NEED_STUBS" -eq 1 ]; then cat >> "$PKG_FILE" <<'EOF'
    .target(name: "PlatformStubs", dependencies: []),
EOF
  fi
  cat >> "$PKG_FILE" <<'EOF'
    .testTarget(name: "CalculatorTests", dependencies: ["Calculator"]),
  ]
)
EOF
fi
# Create Calculator source if missing
mkdir -p "$WORKSPACE/Sources/Calculator"
if [ ! -f "$WORKSPACE/Sources/Calculator/Calculator.swift" ]; then
  cat > "$WORKSPACE/Sources/Calculator/Calculator.swift" <<'EOF'
public struct Calculator {
  public init() {}
  public func add(_ a: Int, _ b: Int) -> Int { a + b }
  public func subtract(_ a: Int, _ b: Int) -> Int { a - b }
  public func multiply(_ a: Int, _ b: Int) -> Int { a * b }
  public func divide(_ a: Int, _ b: Int) -> Int? { b == 0 ? nil : (a / b) }
}
EOF
fi
# Conditional PlatformStubs
if [ "$NEED_STUBS" -eq 1 ]; then
  mkdir -p "$WORKSPACE/Sources/PlatformStubs"
  if [ ! -f "$WORKSPACE/Sources/PlatformStubs/PlatformStubs.swift" ]; then
    cat > "$WORKSPACE/Sources/PlatformStubs/PlatformStubs.swift" <<'EOF'
#if os(Linux)
public enum PlatformView { case stub }
#else
import Foundation
public enum PlatformView { case native }
#endif
EOF
  fi
fi
# Tests
mkdir -p "$WORKSPACE/Tests/CalculatorTests"
if [ ! -f "$WORKSPACE/Tests/CalculatorTests/CalculatorTests.swift" ]; then
  cat > "$WORKSPACE/Tests/CalculatorTests/CalculatorTests.swift" <<'EOF'
import XCTest
@testable import Calculator
final class CalculatorTests: XCTestCase {
  func testAdd() throws { XCTAssertEqual(Calculator().add(2,3), 5) }
  func testSubtract() throws { XCTAssertEqual(Calculator().subtract(5,3), 2) }
  func testMultiply() throws { XCTAssertEqual(Calculator().multiply(4,3), 12) }
  func testDivide() throws { XCTAssertEqual(Calculator().divide(10,2), Optional(5)) }
  func testDivideByZero() throws { XCTAssertNil(Calculator().divide(1,0)) }
}
EOF
fi
# helper scripts (swift-build.sh, swift-test.sh)
cat > "$WORKSPACE/swift-build.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ "${SWIFT_DISABLE_SANDBOX:-0}" = "1" ]; then swift build --disable-sandbox; else swift build; fi
EOF
chmod +x "$WORKSPACE/swift-build.sh"
cat > "$WORKSPACE/swift-test.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [ "${SWIFT_DISABLE_SANDBOX:-0}" = "1" ]; then swift test --disable-sandbox; else swift test; fi
EOF
chmod +x "$WORKSPACE/swift-test.sh"
# record notice if stubs were detected
if [ "$NEED_STUBS" -eq 1 ]; then echo "iOS-specific imports detected: PlatformStubs added to Package.swift; keep UI code isolated" > "$WORKSPACE/PLATFORM_STUBS_NOTICE.txt"; fi
exit 0
