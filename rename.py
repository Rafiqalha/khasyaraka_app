import os
import re

def replace_in_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        return False

    new_content = content
    # Replace KHASYARAKA -> PRADIGI
    new_content = re.sub(r'KHASYARAKA', 'PRADIGI', new_content)
    # Replace Khasyaraka -> Pradigi
    new_content = re.sub(r'Khasyaraka', 'Pradigi', new_content)
    # Replace khasyaraka -> pradigi
    new_content = re.sub(r'khasyaraka', 'pradigi', new_content)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    root_dir = '/home/rafiqalha/projects/khasyaraka'
    exclude_dirs = {'.git', 'node_modules', 'build', '.dart_tool', '.idea', '.gradle', 'Pods', 'out', 'bin'}
    
    changed_files = 0
    for dirpath, dirnames, filenames in os.walk(root_dir, topdown=True):
        # Exclude directories
        dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
        
        for filename in filenames:
            if filename == 'rename.py':
                continue
            if filename.endswith('.png') or filename.endswith('.jpg') or filename.endswith('.ico') or filename.endswith('.sqlite') or filename.endswith('.db') or filename.endswith('.DS_Store') or filename.endswith('.ttf') or filename.endswith('.wav'):
                continue
            
            filepath = os.path.join(dirpath, filename)
            if replace_in_file(filepath):
                changed_files += 1
                
    print(f"Replaced text in {changed_files} files.")
    
if __name__ == '__main__':
    main()
