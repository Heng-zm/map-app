import re
from pathlib import Path

def main():
    content = Path("MapViewer.xcodeproj/project.pbxproj").read_text(encoding="utf-8")

    file_refs = {}
    for line in content.splitlines():
        if "isa = PBXFileReference" in line:
            m = re.search(r'([0-9A-F]{24})\s+/\*\s+(.*?)\s+\*/\s+=\s+\{.*path\s*=\s*([^;]+);', line)
            if m:
                fid, name, path_val = m.groups()
                clean_path = path_val.strip().strip('"')
                file_refs[fid] = (name.strip(), clean_path)

    # Extract PBXGroup section
    sec_match = re.search(r'/\* Begin PBXGroup section \*/(.*?)/\* End PBXGroup section \*/', content, re.DOTALL)
    if not sec_match:
        print("Could not find PBXGroup section")
        return
    sec = sec_match.group(1)

    groups = {}
    # Split by group entries: \t\t[ID] ... = { ... };
    entries = re.findall(r'([0-9A-F]{24})\s*(?:/\*\s*(.*?)\s*\*/)?\s*=\s*\{(.*?)\n\t\t\};', sec, re.DOTALL)
    for gid, gname, body in entries:
        m_path = re.search(r'path\s*=\s*([^;]+);', body)
        gpath = m_path.group(1).strip().strip('"') if m_path else ""
        m_children = re.search(r'children\s*=\s*\((.*?)\);', body, re.DOTALL)
        children = []
        if m_children:
            for c in m_children.group(1).split(","):
                c_clean = c.strip().split("/*")[0].strip()
                if c_clean:
                    children.append(c_clean)
        groups[gid] = {
            "name": (gname or "").strip(),
            "path": gpath,
            "children": children
        }

    root_id = "000100012C00000100000002"
    missing = []
    found_count = 0

    def resolve(gid, current_path):
        nonlocal found_count
        g = groups.get(gid)
        if not g:
            return
        p = current_path
        if g["path"]:
            p = p / g["path"]
        for cid in g["children"]:
            if cid in file_refs:
                fname, fpath = file_refs[cid]
                # Products or system files skip
                if fpath.endswith(".app") or fpath.endswith(".xctest") or fpath.endswith(".entitlements"):
                    continue
                full = p / fpath
                if not full.exists():
                    missing.append((fname, str(full)))
                else:
                    found_count += 1
            elif cid in groups:
                resolve(cid, p)

    resolve(root_id, Path("."))
    print(f"Verified files: {found_count} existing on disk.")
    if missing:
        print(f"ERROR: {len(missing)} files could NOT be found on disk:")
        for name, full in missing:
            print(f"  [MISSING] {name} -> {full}")
    else:
        print("ALL project files resolved successfully to disk!")

if __name__ == "__main__":
    main()
