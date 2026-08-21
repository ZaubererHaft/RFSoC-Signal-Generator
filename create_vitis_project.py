import os
import vitis

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
WORKSPACE_DIR = os.path.join(BASE_DIR, "vitis-ws")
XSA_PATH = os.path.join(BASE_DIR, "main_wrapper.xsa")

if not os.path.exists(XSA_PATH):
    print("XSA does not exist - please export it from vivado after bitsream generation")
    exit()

if not os.path.exists(WORKSPACE_DIR):
    os.makedirs(WORKSPACE_DIR)

client = vitis.create_client()
client.set_workspace(WORKSPACE_DIR)

print("--> Creating platform...")
platform = client.create_platform_component(
    name="platform",
    hw_design=XSA_PATH,
    os="standalone", # "freertos", "linux"
    cpu="psu_cortexa53_0" 
)

print("--> Creating application...")
app = client.create_app_component(
    name="application",
    platform="./vitis-ws/platform/export/platform/platform.xpfm",
    domain="standalone_domain"
)

SRC_DIR = os.path.abspath("./src-ps")
if os.path.exists(SRC_DIR):
    files_to_import = os.listdir(SRC_DIR)
    
    if files_to_import:
        print(f"--> Import files from {SRC_DIR}: {files_to_import}")
        
        app.import_files(
            from_loc=SRC_DIR,
            files=files_to_import,
            dest_dir_in_cmp="src",
            is_skip_copy_sources=True
        )
    else:
        print("'src' folder is empty!")
else:
    print(f"Error: '{SRC_DIR}' does not exist!")


print("--> Creating build...")
app.build()
print("--> Done!")