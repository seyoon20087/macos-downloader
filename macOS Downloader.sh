#!/bin/bash

parameters="${1}${2}${3}${4}${5}${6}${7}${8}${9}"

Escape_Variables()
{
	text_progress="\033[38;5;113m"
	text_success="\033[38;5;113m"
	text_warning="\033[38;5;221m"
	text_error="\033[38;5;203m"
	text_message="\033[38;5;75m"

	text_bold="\033[1m"
	text_faint="\033[2m"
	text_italic="\033[3m"
	text_underline="\033[4m"

	erase_style="\033[0m"
	erase_line="\033[0K"

	move_up="\033[1A"
	move_down="\033[1B"
	move_foward="\033[1C"
	move_backward="\033[1D"
}

Parameter_Variables()
{
	if [[ $parameters == *"-v"* || $parameters == *"-verbose"* ]]; then
		verbose="1"
		set -x
	fi
}

Path_Variables()
{
	script_path="${0}"
	directory_path="${0%/*}"

	resources_path="$directory_path/resources"
}

Input_Off()
{
	stty -echo
}

Input_On()
{
	stty echo
}

Output_Off()
{
	if [[ $verbose == "1" ]]; then
		"$@"
	else
		"$@" &>/dev/null
	fi
}

Check_Environment()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system environment."${erase_style}

		if [ -d /Install\ *.app ]; then
			environment="installer"
		fi

		if [ ! -d /Install\ *.app ]; then
			environment="system"
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system environment."${erase_style}
}

Check_Root()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for root permissions."${erase_style}

	if [[ $environment == "installer" ]]; then
		root_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
	else

		if [[ $(whoami) == "root" && $environment == "system" ]]; then
			root_check="passed"
			echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Root permissions check passed."${erase_style}
		fi

		if [[ ! $(whoami) == "root" && $environment == "system" ]]; then
			root_check="failed"
			echo -e $(date "+%b %m %H:%M:%S") ${text_warning}"- Root permissions check failed."${erase_style}
		fi

	fi
}

Check_Volume_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system version."${erase_style}

		volume_version="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion)"
		volume_version_short="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-5)"
	
		volume_build="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductBuildVersion)"

		if [[ ${#volume_version} == "6" ]]; then
			volume_version_short="$(defaults read /System/Library/CoreServices/SystemVersion.plist ProductVersion | cut -c-4)"
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Checked system version."${erase_style}
}

Check_Volume_Support()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking system support."${erase_style}

	if [[ $volume_version_short == "10."[7-9] || $volume_version_short == "10.1"[0-5] ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ System support check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- System support check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool on a supported system."${erase_style}

		Input_On
		exit
	fi
}

Check_Resources()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for resources."${erase_style}

	if [[ -d "$resources_path" ]]; then
		resources_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Resources check passed."${erase_style}
	fi

	if [[ ! -d "$resources_path" ]]; then
		resources_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Resources check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with the required resources."${erase_style}

		Input_On
		exit
	fi
}

Check_Internet()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for internet conectivity."${erase_style}

	if [[ $(ping -c 2 www.google.com) == *transmitted* && $(ping -c 2 www.google.com) == *received* ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Integrity conectivity check passed."${erase_style}
	else
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Integrity conectivity check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool while connected to the internet."${erase_style}

		Input_On
		exit
	fi
}

Input_Folder()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What save folder would you like to use?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input a save folder path."${erase_style}

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " save_folder
	Input_Off
}

Check_Write()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Checking for write permissions on save folder."${erase_style}

	if [[ -w "$save_folder" ]]; then
		write_check="passed"
		echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Write permissions check passed."${erase_style}
	else
		root_check="failed"
		echo -e $(date "+%b %m %H:%M:%S") ${text_error}"- Write permissions check failed."${erase_style}
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Run this tool with a writable save folder."${erase_style}

		Input_On
		exit
	fi
}

Input_Version()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What operation would you like to run?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Catalina"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Mojave"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     3 - High Sierra"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     4 - Sierra"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     5 - El Capitan"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     6 - Yosemite"${erase_style}


	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " operation_version
	Input_Off

	if [[ $operation_version == "1" ]]; then
		installer_choice="c"
	fi

	if [[ $operation_version == "2" ]]; then
		installer_choice="m"
	fi

	if [[ $operation_version == "3" ]]; then
		installer_choice="hs"
	fi

	if [[ $operation_version == "4" ]]; then
		installer_choice="s"
	fi

	if [[ $operation_version == "5" ]]; then
		installer_choice="ec"
	fi

	if [[ $operation_version == "6" ]]; then
		installer_choice="y"
	fi

	if [[ $operation_version == [1-3] ]]; then
		Import_Catalog
		Import_Second_Catalog
		Input_Download
		Import_Second_Catalog
	fi

	if [[ $operation_version == [4-6] ]]; then
		Import_Catalog
		Import_Second_Catalog
		Download_Installer_2
		Prepare_Installer_2
		Import_Second_Catalog
	fi
}

Import_Catalog()
{
	chmod +x "$resources_path"/curl
	
	if [[ -f "$directory_path"/Catalog.sh ]]; then
		chmod +x "$directory_path"/Catalog.sh
		source "$directory_path"/Catalog.sh
	else
		"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/Catalog.sh https://github.com/rmc-team/macos-downloader/raw/master/Catalog.sh
	
		chmod +x /tmp/Catalog.sh
		source /tmp/Catalog.sh
	fi

	update_option="${installer_choice}_update_option"
	combo_update_option="${installer_choice}_combo_update_option"

	installer_url="${installer_choice}_installer_url"
	installer_key="${installer_choice}_installer_key"
	installer_name="${installer_choice}_installer_name"
	installer_version="${installer_choice}_installer_version"

	update_url="${installer_choice}_update_url"
	update_key="${installer_choice}_update_key"
	update_version="${installer_choice}_update_version"

	combo_update_url="${installer_choice}_combo_update_url"
	combo_update_key="${installer_choice}_combo_update_key"
}

Input_Download()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ What operation would you like to run?"${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Input an operation number."${erase_style}
	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     1 - Installer"${erase_style}

	if [[ ${!update_option} == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     2 - Beta Update"${erase_style}
	fi

	if [[ ${!combo_update_option} == "1" ]]; then
		echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/     3 - Beta Combo Update"${erase_style}
	fi

	Input_On
	read -e -p "$(date "+%b %m %H:%M:%S") / " operation_download
	Input_Off

	if [[ $operation_download == "1" ]]; then
		Download_Installer
		Prepare_Installer
	fi

	if [[ $operation_download == "2" ]]; then
		update_name="macOSUpd"
		update_url="${!update_url}"
		update_key="${!update_key}"
		update_version="${!update_version}"
	fi

	if [[ $operation_download == "3" ]]; then
		update_name="macOSUpdCombo"
		update_url="${!combo_update_url}"
		update_key="${!combo_update_key}"
		update_version="${!combo_update_version}"
	fi

	if [[ $operation_download == [2-3] ]]; then
		Download_Update
		Prepare_Update
	fi
}

Import_Second_Catalog()
{
	if [[ -d /tmp/"${!installer_name}" ]]; then
		chmod +x /tmp/"${!installer_name}"/Catalog.sh
		source /tmp/"${!installer_name}"/Catalog.sh
	fi

	if [[ -d /tmp/"${update_name}${update_version}" ]]; then
		chmod +x /tmp/"${update_name}${update_version}"/Catalog.sh
		source /tmp/"${update_name}${update_version}"/Catalog.sh
	fi
}

Download_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Downloading installer files."${erase_style}

		if [[ ! -d /tmp/"${!installer_name}" ]]; then
			mkdir /tmp/"${!installer_name}"
		fi

		echo -e "installer_download=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
	
		if [[ ! "$InstallAssistantAuto_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/InstallAssistantAuto.pkg http://swcdn.apple.com/content/downloads/${!installer_url}/InstallAssistantAuto.pkg
			echo -e "InstallAssistantAuto_pkg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi
	
		if [[ ! "$AppleDiagnostics_chunklist" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/AppleDiagnostics.chunklist http://swcdn.apple.com/content/downloads/${!installer_url}/AppleDiagnostics.chunklist
			echo -e "AppleDiagnostics_chunklist=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi
	
		if [[ ! "$AppleDiagnostics_dmg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/AppleDiagnostics.dmg http://swcdn.apple.com/content/downloads/${!installer_url}/AppleDiagnostics.dmg
			echo -e "AppleDiagnostics_dmg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi
	
		if [[ ! "$BaseSystem_chunklist" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/BaseSystem.chunklist http://swcdn.apple.com/content/downloads/${!installer_url}/BaseSystem.chunklist
			echo -e "BaseSystem_chunklist=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi
	
		if [[ ! "$BaseSystem_dmg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/BaseSystem.dmg http://swcdn.apple.com/content/downloads/${!installer_url}/BaseSystem.dmg
			echo -e "BaseSystem_dmg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi
	
		if [[ ! "$InstallESD_dmg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/InstallESD.dmg http://swcdn.apple.com/content/downloads/${!installer_url}/InstallESDDmg.pkg
			echo -e "InstallESD_dmg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		echo -e "installer_download=\"2\"" >> /tmp/"${!installer_name}"/Catalog.sh

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Downloaded installer files."${erase_style}
}

Prepare_Installer()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Preparing installer."${erase_style}

		echo -e "installer_prepare=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh

		cd /tmp/"${!installer_name}"
	
		if [[ ! "$InstallAssistantAuto_pkg" == "2" ]]; then
			chmod +x "$resources_path"/pbzx
			"$resources_path"/pbzx /tmp/"${!installer_name}"/InstallAssistantAuto.pkg | Output_Off cpio -i
			echo -e "InstallAssistantAuto_pkg=\"2\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi


		if [[ ! "$InstallAssistantAuto_pkg" == "3" ]]; then
			mv /tmp/"${!installer_name}"/"${!installer_name}".app "$save_folder"
			echo -e "InstallAssistantAuto_pkg=\"3\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$AppleDiagnostics_chunklist" == "3" ]]; then
			mv /tmp/"${!installer_name}"/AppleDiagnostics.chunklist "$save_folder"/"${!installer_name}".app/Contents/SharedSupport
			echo -e "AppleDiagnostics_chunklist=\"3\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$AppleDiagnostics_dmg" == "3" ]]; then
			mv /tmp/"${!installer_name}"/AppleDiagnostics.dmg "$save_folder"/"${!installer_name}".app/Contents/SharedSupport
			echo -e "AppleDiagnostics_dmg=\"3\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$BaseSystem_chunklist" == "3" ]]; then
			mv /tmp/"${!installer_name}"/BaseSystem.chunklist "$save_folder"/"${!installer_name}".app/Contents/SharedSupport
			echo -e "BaseSystem_chunklist=\"3\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$BaseSystem_dmg" == "3" ]]; then
			mv /tmp/"${!installer_name}"/BaseSystem.dmg "$save_folder"/"${!installer_name}".app/Contents/SharedSupport
			echo -e "BaseSystem_dmg=\"3\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$InstallESD_dmg" == "3" ]]; then
			mv /tmp/"${!installer_name}"/InstallESD.dmg "$save_folder"/"${!installer_name}".app/Contents/SharedSupport
			echo -e "InstallESD_dmg=\"3\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		echo -e "installer_prepare=\"2\"" >> /tmp/"${!installer_name}"/Catalog.sh

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Prepared installer."${erase_style}
}

Download_Installer_2()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Downloading installer files."${erase_style}

		if [[ ! -d /tmp/"${!installer_name}" ]]; then
			mkdir /tmp/"${!installer_name}"
		fi

		echo -e "installer_download=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
	
		if [[ ! "$Install_dmg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${!installer_name}"/"${!installer_name}".dmg ${!installer_url}
			echo -e "Install_dmg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		echo -e "installer_download=\"2\"" >> /tmp/"${!installer_name}"/Catalog.sh

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Downloaded installer files."${erase_style}
}

Prepare_Installer_2()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Preparing installer."${erase_style}

		echo -e "installer_prepare=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		Output_Off hdiutil attach /tmp/"${!installer_name}"/"${!installer_name}".dmg -mountpoint /tmp/"${!installer_name}"_dmg -nobrowse

		installer_pkg="$(ls /tmp/"${!installer_name}"_dmg)"
		installer_pkg_partial="${installer_pkg%.*}"

		if [[ ! "$Install_pkg" == "1" ]]; then
			pkgutil --expand /tmp/"${!installer_name}"_dmg/"${installer_pkg}" /tmp/"${!installer_name}"/"${installer_pkg_partial}"
			echo -e "Install_pkg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$Install_pkg" == "2" ]]; then
			tar -xf /tmp/"${!installer_name}"/"${installer_pkg_partial}"/"${installer_pkg}"/Payload -C "$save_folder"
			echo -e "Install_pkg=\"2\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		if [[ ! "$InstallESD_dmg" == "1" ]]; then
			cp /tmp/"${!installer_name}"_dmg/"${installer_pkg}" "$save_folder"/"${!installer_name}".app/Contents/SharedSupport/InstallESD.dmg
			echo -e "InstallESD_dmg=\"1\"" >> /tmp/"${!installer_name}"/Catalog.sh
		fi

		Output_Off hdiutil detach /tmp/"${!installer_name}"_dmg
		echo -e "installer_prepare=\"2\"" >> /tmp/"${!installer_name}"/Catalog.sh

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Prepared installer."${erase_style}
}

Download_Update()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Downloading update files."${erase_style}

		if [[ ! -d /tmp/"${update_name}${update_version}" ]]; then
			mkdir /tmp/"${update_name}${update_version}"
		fi

		echo -e "update_download=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh

		if [[ ! "$macOSBrain_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/macOSBrain.pkg http://swcdn.apple.com/content/downloads/${update_url}/macOSBrain.pkg
			echo -e "macOSBrain_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$FirmwareUpdate_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/FirmwareUpdate.pkg http://swcdn.apple.com/content/downloads/${update_url}/FirmwareUpdate.pkg
			echo -e "FirmwareUpdate_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$FullBundleUpdate_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/FullBundleUpdate.pkg http://swcdn.apple.com/content/downloads/${update_url}/FullBundleUpdate.pkg
			echo -e "FullBundleUpdate_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$EmbeddedOSFirmware_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/EmbeddedOSFirmware.pkg http://swcdn.apple.com/content/downloads/${update_url}/EmbeddedOSFirmware.pkg
			echo -e "EmbeddedOSFirmware_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$SecureBoot_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/SecureBoot.pkg http://swcdn.apple.com/content/downloads/${update_url}/SecureBoot.pkg
			echo -e "SecureBoot_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$macOSUpd_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/${update_name}${update_version}.pkg http://swcdn.apple.com/content/downloads/${update_url}/${update_name}${update_version}.pkg
			echo -e "macOSUpd_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$macOSUpd_RecoveryHDUpdate_pkg" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/${update_name}${update_version}.RecoveryHDUpdate.pkg http://swcdn.apple.com/content/downloads/${update_url}/${update_name}${update_version}.RecoveryHDUpdate.pkg
			echo -e "macOSUpd_RecoveryHDUpdate_pkg=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		if [[ ! "$Distribution_dist" == "1" ]]; then
			"$resources_path"/curl --cacert "$resources_path"/cacert.pem -L -s -o /tmp/"${update_name}${update_version}"/${update_key}.dist https://swdist.apple.com/content/downloads/${update_url}/${update_key}.English.dist
			echo -e "Distribution_dist=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		echo -e "update_download=\"2\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Downloaded update files."${erase_style}
}

Prepare_Update()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Preparing update."${erase_style}

		echo -e "update_prepare=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh

		sed -i '' 's|<pkg-ref id="com\.apple\.pkg\.update\.os\.10\.14\.[0-9]\{1,\}Patch\.[a-zA-Z0-9]\{1,\}" auth="Root" packageIdentifier="com\.apple\.pkg\.update\.os\.10\.14\.[0-9]\{1,\}\.[a-zA-Z0-9]\{1,\}" onConclusion="RequireRestart">macOSUpd10\.14\.[0-9]\{1,\}Patch\.pkg<\/pkg-ref>||' /tmp/"${update_name}${update_version}"/${update_key}.dist

		if [[ ! "$productbuild" == "1" ]]; then
			Output_Off productbuild --distribution /tmp/"${update_name}${update_version}"/${update_key}.dist --package-path /tmp/"${update_name}${update_version}" "$save_folder/${update_name}${update_version}.pkg"
			echo -e "productbuild=\"1\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh
		fi

		echo -e "update_prepare=\"2\"" >> /tmp/"${update_name}${update_version}"/Catalog.sh

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Prepared update."${erase_style}
}

End()
{
	echo -e $(date "+%b %m %H:%M:%S") ${text_progress}"> Removing temporary files."${erase_style}

		if [[ "$installer_prepare" == "2" ]]; then
			Output_Off rm -R /tmp/"${!installer_name}"
		fi

		if [[ "$update_prepare" == "2" ]]; then
			Output_Off rm -R /tmp/"${update_name}${update_version}"
		fi

	echo -e $(date "+%b %m %H:%M:%S") ${move_up}${erase_line}${text_success}"+ Removed temporary files."${erase_style}

	echo -e $(date "+%b %m %H:%M:%S") ${text_message}"/ Thank you for using macOS Downloader."${erase_style}

	Input_On
	exit
}

Input_Off
Escape_Variables
Parameter_Variables
Path_Variables
Check_Environment
Check_Root
Check_Resources
Check_Internet
Check_Volume_Version
Check_Volume_Support
Input_Folder
Check_Write
Input_Version
End