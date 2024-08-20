def main():
    editor = LuaEditor(
        "lua",
        ROOT,
        "",
        default_in=PKG_LIST,
        default_out=GENERATED_NIXFILE,
    )

    editor.run()

    print("ttoto")

if __name__ == "__main__":
    main()

