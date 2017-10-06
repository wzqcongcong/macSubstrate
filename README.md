# macSubstrate - Substrate for macOS #

### What is macSubstrate

**macSubstrate** is a platform for interprocess code injection on macOS, with the similar function to [Cydia Substrate](http://www.cydiasubstrate.com/) on iOS.

Using macSubstrate, you can inject your plugin (*.bundle* or *.framework*) into a mac app (*including sandboxed apps*) to tweak it in the runtime. No trouble with modification or codesign for the target app, all you need is to get or create a plugin, and then leave the injection job to macSubstrate.

Moreover, macSubstrate provides a GUI app to make injection much easier. You can get a plugin from other developers, just like downloading a plugin from Cydia on iOS, then install the plugin using macSubstrate. That is it! macSubstrate will load the plugin automatically, and whenever the target app is relaunched, macSubstrate will take care of it for you.

### Prepare

* [Disable SIP](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html)

* [Why should disable SIP](https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_11.html)

    `System Integrity Protection is a new security policy that applies to every running process, including privileged code and code that runs out of the sandbox. The policy extends additional protections to components on disk and at run-time, only allowing system binaries to be modified by the system installer and software updates. Code injection and runtime attachments to system binaries are no longer permitted.`

### Usage

1. download and launch the macSubstrate app.
2. grant authorization if needed.
3. install a plugin by importing or dragging into macSubstrate.
4. launch the target app.

    *(step 3 and step 4 can be switched)*

    Once a plugin is installed by macSubstrate, it will take effect immediately. But if you want it to work after restarting your mac, you need to allow macSubstrate to automatically launch at login.

5. uninstall a plugin by macSubstrate when you do not need it anymore.

### Plugin

macSubstrate supports plugins of **.bundle** or **.framework**, so you just need to create a valid *.bundle* or *.framework* file. The most important thing is to add a key **macSubstratePlugin** into the *info.plist*, with the dictionary value:

* **TargetAppBundleID**: the target app's *CFBundleIdentifier*, this tells macSubstrate which app to inject.
* **Description**: brief description of the plugin.
* **AuthorName**: author name of the plugin.
* **AuthorEmail**: author email of the plugin.

Please check the demo plugin for details.

### Security

1. SIP is a new security policy on macOS, which will help to keep you away from potential security risk. Disable it means you will lose the protection from SIP.
2. If you install a plugin from a developer, you should be responsible for the security of the plugin. If you do not trust it, please do not install it. macSubstrate will help to verify the codesign of a plugin, and help to scan it using [VirusTotal](https://www.virustotal.com). But anyway, macSubstrate is just a tool, and it is your choice to decide what plugin to install.

### Thanks

macSubstrate is inspired and created with the help of following projects:

* [Cydia Substrate](http://www.cydiasubstrate.com/)
* [mach_inject](https://github.com/rentzsch/mach_inject)
