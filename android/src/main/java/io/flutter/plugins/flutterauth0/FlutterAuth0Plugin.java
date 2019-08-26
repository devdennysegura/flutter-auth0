package io.flutter.plugins.flutterauth0;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
// import android.os.Handler;
import androidx.browser.customtabs.CustomTabsIntent;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;
import java.util.Map;

import io.flutter.plugins.flutterauth0.common.AuthenticationFactory;

/** Flutter plugin for Auth0. */
public class FlutterAuth0Plugin implements MethodCallHandler {
    private static final String TAG = FlutterAuth0Plugin.class.getName();
    private static Registrar registrar;
    private static final String CHANNEL = "io.flutter.plugins/auth0";
    private static final int REQUEST = 1;
    private static Result response;

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
        FlutterAuth0Plugin instance = new FlutterAuth0Plugin(registrar);
        channel.setMethodCallHandler(instance);
    }

    private FlutterAuth0Plugin(Registrar pluginRegister) {
        super();
        registrar = pluginRegister;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        response = result;
        if (call.method.equals("authorize")) {
            authorize(call);
        } else if (call.method.equals("parameters")) {
            getOauthParameters(result);
        } else if (call.method.equals("bundleIdentifier")) {
            getBundleIdentifier(result);
        } else {
            result.notImplemented();
        }
    }

    @SuppressWarnings("unchecked")
    public void getBundleIdentifier(Result result) {
        String packageName = AuthenticationFactory.getIdentifier(registrar.context());
        result.success(packageName);
    }

    private void getOauthParameters(Result result) {
        Map<String, Object> params = AuthenticationFactory.getAuthParameters();
        result.success(params);
    }

    private void authorize(MethodCall call) {
        final String url = (String) call.arguments;
        final Activity activity = registrar.activity();
        CustomTabsIntent.Builder builder = new CustomTabsIntent.Builder();
        CustomTabsIntent customTabsIntent = builder.build();
        customTabsIntent.launchUrl(activity, Uri.parse(url));
    }

    public static Activity getActivity() {
        return registrar.activity();
    }

    public static void resolve(String code, String error) {
        if (error != null)
            response.error("ACTIVITY_FAILURE", error, null);
        response.success(code);
    }

}