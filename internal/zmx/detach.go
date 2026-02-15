package zmx

import (
	"net"
	"os"
	"os/user"
	"path/filepath"
)

var detachBytes = []byte{0x04, 0x00, 0x00, 0x00, 0x00}

func resolveDir() string {
	if dir := os.Getenv("ZMX_DIR"); dir != "" {
		return dir
	}

	if xdg := os.Getenv("XDG_RUNTIME_DIR"); xdg != "" {
		return filepath.Join(xdg, "zmx")
	}

	u, err := user.Current()
	if err != nil {
		return ""
	}

	return filepath.Join(os.TempDir(), "zmx-"+u.Uid)
}

func DetachAll() {
	dir := resolveDir()
	if dir == "" {
		return
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		return
	}

	for _, entry := range entries {
		path := filepath.Join(dir, entry.Name())

		info, err := os.Stat(path)
		if err != nil || info.Mode()&os.ModeSocket == 0 {
			continue
		}

		conn, err := net.Dial("unix", path)
		if err != nil {
			continue
		}

		conn.Write(detachBytes)
		conn.Close()
	}
}
