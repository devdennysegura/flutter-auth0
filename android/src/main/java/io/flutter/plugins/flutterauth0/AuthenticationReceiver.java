package io.flutter.plugins.flutterauth0;

import android.app.Activity;
import android.content.Intent;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import io.flutter.plugins.flutterauth0.FlutterAuth0Plugin;

public class AuthenticationReceiver extends Activity {
    private static final String TAG = AuthenticationReceiver.class.getName();

    public static final String EXTRA_CODE = "Auth0Code";
    public static final String EXTRA_ERROR = "Auth0Error";

    public void onCreate(Bundle savedInstanceBundle) {
        super.onCreate(savedInstanceBundle);
        Intent intent = this.getIntent();
        Uri uri = intent.getData();
        String access_token = uri.getQueryParameter("code");
        String error = uri.getQueryParameter("error");
        closeView(access_token, error);
    }

    private void closeView(String token, String errorMessage) {
        Intent intent = new Intent(AuthenticationReceiver.this, FlutterAuth0Plugin.getActivity().getClass());
        intent.putExtra(EXTRA_CODE, token);
        intent.putExtra(EXTRA_ERROR, errorMessage);
        if (errorMessage != null)
            setResult(Activity.RESULT_CANCELED, intent);
        else
            setResult(Activity.RESULT_OK, intent);
        intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        FlutterAuth0Plugin.resolve(token, errorMessage);
        startActivityIfNeeded(intent, 0);
        finish();
    }

}
