package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.afur.flutterhtmltopdf.FlutterHtmlToPdfPlugin;
import com.octapush.moneyformatter.fluttermoneyformatter.FlutterMoneyFormatterPlugin;
import de.lrosenberg.flutterpdfrenderer.FlutterPdfRendererPlugin;
import com.eyedeadevelopers.fluttertts.FlutterTtsPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.share.SharePlugin;
import com.zt.shareextend.ShareExtendPlugin;
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import com.juanito21.simpleshare.SimpleSharePlugin;
import com.tekartik.sqflite.SqflitePlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterHtmlToPdfPlugin.registerWith(registry.registrarFor("com.afur.flutterhtmltopdf.FlutterHtmlToPdfPlugin"));
    FlutterMoneyFormatterPlugin.registerWith(registry.registrarFor("com.octapush.moneyformatter.fluttermoneyformatter.FlutterMoneyFormatterPlugin"));
    FlutterPdfRendererPlugin.registerWith(registry.registrarFor("de.lrosenberg.flutterpdfrenderer.FlutterPdfRendererPlugin"));
    FlutterTtsPlugin.registerWith(registry.registrarFor("com.eyedeadevelopers.fluttertts.FlutterTtsPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    SharePlugin.registerWith(registry.registrarFor("io.flutter.plugins.share.SharePlugin"));
    ShareExtendPlugin.registerWith(registry.registrarFor("com.zt.shareextend.ShareExtendPlugin"));
    SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
    SimpleSharePlugin.registerWith(registry.registrarFor("com.juanito21.simpleshare.SimpleSharePlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
