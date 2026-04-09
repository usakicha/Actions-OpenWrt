Place files here to merge into OpenWrt source tree after diy-part1.sh.

Example:
- custom/package/my-app/...
- custom/target/linux/xxx/...

Workflow behavior:
- The workflow runs diy-part1.sh first.
- Then it merges custom/ into openwrt/ via rsync -a.
- Existing files in OpenWrt can be overwritten by files from custom/.
