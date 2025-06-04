#!/usr/bin/env bash

# .NET SDK CLI Bash Completion Script
# POSIX compliant bash completion for dotnet command
# Source this file in your ~/.bashrc or ~/.bash_profile
#
# Author: Wolandark
# Github Location: https://github.com/wolandark/dotnet-bash-completion

_dotnet_completion() {
    local cur prev words cword
    _init_completion || return

    # Main dotnet commands
    local commands="new restore build publish run test pack clean sln add remove list
                   nuget tool workload help --version --info --list-sdks --list-runtimes"

    # Global options that work with most commands
    local global_opts="--help -h --verbosity -v --configuration -c --framework -f
                      --runtime -r --output -o --no-restore --interactive"

    # Command-specific options
    local new_opts="--list -l --type -lang --language --name -n --output -o --force
                   --dry-run --no-update-check --use-program-main --no-https --exclude-launch-settings
                   --no-restore --auth --aad-b2c-instance --susi-policy-id --aad-instance
                   --client-id --domain --tenant-id --callback-path --use-local-db --use-sqlite
                   --individual --windows-auth --use-controllers --minimal --kestrel-http-port
                   --kestrel-https-port --no-openapi --use-browser-link --include-sample-data"
    local build_opts="--configuration -c --framework -f --runtime -r --output -o
                     --verbosity -v --no-restore --no-dependencies --force --no-incremental"
    local run_opts="--configuration -c --framework -f --runtime -r --project -p
                   --launch-profile --no-launch-profile --no-build --no-restore"
    local test_opts="--settings -s --list-tests -t --filter --logger -l --output -o
                    --results-directory -r --collect --no-build --no-restore"
    local publish_opts="--configuration -c --framework -f --runtime -r --output -o
                       --self-contained --no-self-contained --verbosity -v"
    local pack_opts="--configuration -c --output -o --no-build --include-symbols
                    --include-source --verbosity -v --version-suffix"
    local sln_opts="add remove list"
    local add_opts="package reference project"
    local remove_opts="package reference"
    local nuget_opts="push delete locals list source add remove update enable disable"
    local tool_opts="install uninstall update list run search"
    local workload_opts="install uninstall update list search restore repair"

    # Project templates for 'dotnet new'
    local templates="console classlib web webapi mvc razor blazor blazorserver blazorwasm
                    winforms wpf worker grpc nunit mstest xunit gitignore editorconfig
                    nugetconfig webconfig sln globaljson tool-manifest proto angular react
                    reactredux page viewimports viewstart razorcomponent"

    # Verbosity levels
    local verbosity_levels="quiet minimal normal detailed diagnostic"

    # Configuration values
    local configurations="Debug Release"

    # Special handling for 'dotnet new' command with multiple words
    if [ "${words[1]}" = "new" ] && [ "${#words[@]}" -gt 2 ]; then
        local template="${words[2]}"

        # Check if the template is valid
        if echo "${templates}" | grep -q "\\b${template}\\b"; then
            # We're in a 'dotnet new template ...' context
            case "${cur}" in
                --*)
                    COMPREPLY=($(compgen -W "${new_opts}" -- "${cur}"))
                    ;;
                *)
                    # If not starting with --, offer options
                    COMPREPLY=($(compgen -W "${new_opts}" -- "${cur}"))
                    ;;
            esac
            return 0
        fi
    fi

    case "${prev}" in
        dotnet)
            COMPREPLY=($(compgen -W "${commands}" -- "${cur}"))
            return 0
            ;;
        new)
            case "${cur}" in
                --*)
                    COMPREPLY=($(compgen -W "${new_opts}" -- "${cur}"))
                    ;;
                *)
                    COMPREPLY=($(compgen -W "${templates}" -- "${cur}"))
                    ;;
            esac
            return 0
            ;;
        build)
            COMPREPLY=($(compgen -W "${build_opts}" -- "${cur}"))
            return 0
            ;;
        run)
            COMPREPLY=($(compgen -W "${run_opts}" -- "${cur}"))
            return 0
            ;;
        test)
            COMPREPLY=($(compgen -W "${test_opts}" -- "${cur}"))
            return 0
            ;;
        publish)
            COMPREPLY=($(compgen -W "${publish_opts}" -- "${cur}"))
            return 0
            ;;
        pack)
            COMPREPLY=($(compgen -W "${pack_opts}" -- "${cur}"))
            return 0
            ;;
        clean|restore)
            COMPREPLY=($(compgen -W "--help -h --verbosity -v --configuration -c" -- "${cur}"))
            return 0
            ;;
        sln)
            COMPREPLY=($(compgen -W "${sln_opts}" -- "${cur}"))
            return 0
            ;;
        add)
            COMPREPLY=($(compgen -W "${add_opts}" -- "${cur}"))
            return 0
            ;;
        remove)
            COMPREPLY=($(compgen -W "${remove_opts}" -- "${cur}"))
            return 0
            ;;
        nuget)
            COMPREPLY=($(compgen -W "${nuget_opts}" -- "${cur}"))
            return 0
            ;;
        tool)
            COMPREPLY=($(compgen -W "${tool_opts}" -- "${cur}"))
            return 0
            ;;
        workload)
            COMPREPLY=($(compgen -W "${workload_opts}" -- "${cur}"))
            return 0
            ;;
        --verbosity|-v)
            COMPREPLY=($(compgen -W "${verbosity_levels}" -- "${cur}"))
            return 0
            ;;
        --configuration|-c)
            COMPREPLY=($(compgen -W "${configurations}" -- "${cur}"))
            return 0
            ;;
        --framework|-f)
            # Try to get available frameworks from dotnet --list-runtimes
            if command -v dotnet >/dev/null 2>&1; then
                local frameworks
                frameworks=$(dotnet --list-runtimes 2>/dev/null | \
                           sed -n 's/^[^0-9]*\([0-9][^[:space:]]*\).*/\1/p' | \
                           sort -u 2>/dev/null)
                if [ -n "${frameworks}" ]; then
                    COMPREPLY=($(compgen -W "${frameworks}" -- "${cur}"))
                    return 0
                fi
            fi
            # Fallback to common frameworks
            COMPREPLY=($(compgen -W "net8.0 net7.0 net6.0 net5.0 netcoreapp3.1 netstandard2.1 netstandard2.0" -- "${cur}"))
            return 0
            ;;
        --output|-o|--results-directory)
            # Complete directories
            COMPREPLY=($(compgen -d -- "${cur}"))
            return 0
            ;;
        --project|-p)
            # Complete .csproj, .fsproj, .vbproj files and directories
            COMPREPLY=($(compgen -f -X '!*.@(csproj|fsproj|vbproj)' -- "${cur}"))
            COMPREPLY+=($(compgen -d -- "${cur}"))
            return 0
            ;;
        --type)
            # For dotnet new --type
            COMPREPLY=($(compgen -W "${templates}" -- "${cur}"))
            return 0
            ;;
        --language|--lang)
            COMPREPLY=($(compgen -W "C# F# VB" -- "${cur}"))
            return 0
            ;;
        --auth)
            COMPREPLY=($(compgen -W "None Individual IndividualB2C SingleOrg MultiOrg Windows" -- "${cur}"))
            return 0
            ;;
        --use-program-main|--no-https|--exclude-launch-settings|--no-restore|--use-local-db|--use-sqlite|--individual|--windows-auth|--use-controllers|--minimal|--no-openapi|--use-browser-link|--include-sample-data)
            # Boolean options - no completion needed
            return 0
            ;;
        --aad-b2c-instance|--susi-policy-id|--aad-instance|--client-id|--domain|--tenant-id|--callback-path)
            # String options that require user input - no completion
            return 0
            ;;
        --kestrel-http-port|--kestrel-https-port)
            # Port numbers - suggest common ports
            COMPREPLY=($(compgen -W "5000 5001 8080 8443 3000 3001" -- "${cur}"))
            return 0
            ;;
    esac

    # Handle multi-word commands like "dotnet sln add"
    if [ "${#words[@]}" -gt 2 ]; then
        case "${words[1]} ${words[2]}" in
            "sln add"|"sln remove")
                # Complete project files
                COMPREPLY=($(compgen -f -X '!*.@(csproj|fsproj|vbproj)' -- "${cur}"))
                return 0
                ;;
            "add package")
                # This would ideally complete NuGet package names, but that requires network access
                # For now, just return empty completion
                return 0
                ;;
            "add reference"|"remove reference")
                # Complete project files
                COMPREPLY=($(compgen -f -X '!*.@(csproj|fsproj|vbproj)' -- "${cur}"))
                return 0
                ;;
        esac
    fi

    # Default completion for options
    case "${cur}" in
        --*)
            # Only show basic global options when not in a specific command context
            COMPREPLY=($(compgen -W "--help -h --version --info" -- "${cur}"))
            ;;
        *)
            # Complete files for most other cases
            COMPREPLY=($(compgen -f -- "${cur}"))
            ;;
    esac

    return 0
}

# Check if _init_completion function exists (from bash-completion package)
if ! declare -f _init_completion >/dev/null 2>&1; then
    # Fallback implementation for systems without bash-completion
    _init_completion() {
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=${COMP_CWORD}
    }
fi

# Register the completion function
complete -F _dotnet_completion dotnet

# Also handle 'dn' alias if it exists
if alias dn >/dev/null 2>&1; then
    complete -F _dotnet_completion dn
fi
