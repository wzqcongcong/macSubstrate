# Substrate for macOS #

## What is **macSubstrate**

**macSubstrate** is a platform for interprocess code injection on macOS, just like [Cydia Substrate](http://www.cydiasubstrate.com/) on iOS.

Using macSubstrate, you can inject your codes (*.bundle* or *.framework*) into a mac app (*including sandboxed apps*) to tweak it in the runtime. No trouble with modification or codesign for the target app, all you need is to get or make a plugin, and then leave the injection job to macSubstrate.

Moreover, macSubstrate provides a GUI app to make injection much easier. You can get a plugin from other developers, just like downloading a plugin from Cydia on iOS, then install the plugin using macSubstrate. That is it! macSubstrate will load the plugin automatically, and whenever the target app is relaunched, macSubstrate will take care of it for you.

## Prepare

* [Disable SIP](https://developer.apple.com/library/content/documentation/Security/Conceptual/System_Integrity_Protection_Guide/ConfiguringSystemIntegrityProtection/ConfiguringSystemIntegrityProtection.html)

* [Why should disable SIP](https://developer.apple.com/library/content/releasenotes/MacOSX/WhatsNewInOSX/Articles/MacOSX10_11.html)

    `System Integrity Protection is a new security policy that applies to every running process, including privileged code and code that runs out of the sandbox. The policy extends additional protections to components on disk and at run-time, only allowing system binaries to be modified by the system installer and software updates. Code injection and runtime attachments to system binaries are no longer permitted.`

    *Cydia needs to jailbreak iOS, macSubstrate needs to disable SIP.*

## How to use **macSubstrate**

1. launch macSubstrate.
2. grant authorization if needed.
3. install a plugin by importing or dragging.
4. launch the target app.

    *step 3 and step 4 can be switched.*

The plugin just needs a one-time-only installation, and will take effect immediately. But if you want it to work after restarting your mac, you need to allow macSubstrate to automatically launch at login.

## How to make a plugin

macSubstrate supports plugins of **.bundle** or **.framework**, so you just need to make a valid *.bundle* or *.framework* file. The most important thing is to add a key **macSubstratePluginTargetAppBundleID** into the *info.plist*, with the value of the target app's **CFBundleIdentifier**. This key tells macSubstrate which app to inject.

Please check the demo plugin for details.

## Thanks

**macSubstrate** is inspired and created with the help of following projects:

* [Cydia Substrate](http://www.cydiasubstrate.com/)
* [mach_inject](https://github.com/rentzsch/mach_inject)
