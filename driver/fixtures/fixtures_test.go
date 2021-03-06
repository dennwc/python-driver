package fixtures

import (
	"path/filepath"
	"testing"

	"github.com/bblfsh/python-driver/driver/normalizer"
	"gopkg.in/bblfsh/sdk.v2/sdk/driver"
	"gopkg.in/bblfsh/sdk.v2/sdk/driver/fixtures"
)

const projectRoot = "../../"

var Suite = &fixtures.Suite{
	Lang: "python",
	Ext:  ".py",
	Path: filepath.Join(projectRoot, fixtures.Dir),
	NewDriver: func() driver.BaseDriver {
		return driver.NewExecDriverAt(filepath.Join(projectRoot, "build/bin/native"))
	},
	Transforms: normalizer.Transforms,
	BenchName:  "issue_server101",
	Docker: fixtures.DockerConfig{
		Image: "python:3",
	},
	Semantic: fixtures.SemanticConfig{
		BlacklistTypes: []string{
			"AsyncFunctionDef",
			"Bytes",
			"FunctionDef",
			"ImportFrom",
			"Name",
			"NoopLine",
			"NoopSameLine",
			"Str",
			"StringLiteral",
			"arg",
			"kwarg",
			"kwonly_arg",
			"vararg",
			"alias",
		},
	},
}

func TestPythonDriver(t *testing.T) {
	Suite.RunTests(t)
}

func BenchmarkPythonDriver(b *testing.B) {
	Suite.RunBenchmarks(b)
}
