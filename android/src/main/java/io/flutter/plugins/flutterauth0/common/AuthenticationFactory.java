package io.flutter.plugins.flutterauth0.common;

import android.content.Context;
import android.util.Base64;
import androidx.annotation.NonNull;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.HashMap;
import java.util.Map;

public class AuthenticationFactory {

    private static final String TAG = AuthenticationFactory.class.getName();
    private static final String US_ASCII = "US-ASCII";
    private static final String SHA_256 = "SHA-256";
    private static final int CANCEL_EVENT_DELAY = 100;

    public AuthenticationFactory() {
        super();
    }

    public static String getIdentifier(Context context) {
        return context.getPackageName();
    }

    public static Map<String, Object> getAuthParameters() {
        final String verifier = generateRandomValue();
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("verifier", verifier);
        parameters.put("code_challenge", generateCodeChallenge(verifier));
        parameters.put("code_challenge_method", "S256");
        parameters.put("state", generateRandomValue());
        return parameters;
    }

    private static String getBase64String(byte[] source) {
        return Base64.encodeToString(source, Base64.URL_SAFE | Base64.NO_WRAP | Base64.NO_PADDING);
    }

    private static byte[] getASCIIBytes(String value) {
        byte[] input;
        try {
            input = value.getBytes(US_ASCII);
        } catch (UnsupportedEncodingException e) {
            throw new IllegalStateException("Could not convert string to an ASCII byte array", e);
        }
        return input;
    }

    private static byte[] getSHA256(byte[] input) {
        byte[] signature;
        try {
            MessageDigest md = MessageDigest.getInstance(SHA_256);
            md.update(input, 0, input.length);
            signature = md.digest();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("Failed to get SHA-256 signature", e);
        }
        return signature;
    }

    private static String generateRandomValue() {
        SecureRandom sr = new SecureRandom();
        byte[] code = new byte[32];
        sr.nextBytes(code);
        return getBase64String(code);
    }

    private static String generateCodeChallenge(@NonNull String codeVerifier) {
        byte[] input = getASCIIBytes(codeVerifier);
        byte[] signature = getSHA256(input);
        return getBase64String(signature);
    }
}