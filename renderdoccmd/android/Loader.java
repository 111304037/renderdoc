package @RENDERDOC_ANDROID_PACKAGE_NAME@;
import android.net.Uri;
import android.os.Build;
import android.app.Activity;
import android.provider.Settings;
import android.view.WindowManager;
import android.os.Environment;
import android.content.Intent;

//BRANCH_DEV
import android.net.Uri;
import android.provider.Settings;
//BRANCH_DEV

public class Loader extends android.app.NativeActivity
{
    /* load our native library */
    static {
        System.loadLibrary("renderdoccmd"); // this will load VkLayer_GLES_RenderDoc as well
    }

    @Override
    protected void onCreate(android.os.Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

//BRANCH_DEV
        if(false){
//BRANCH_DEV
        // if we're running on something older than Android M (6.0), return now
        // before requesting permissions as it's not supported
        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.M)
            return;

        String[] permission = new String[1];
        if (Build.VERSION.SDK_INT < 30 /*Build.VERSION_CODES.R*/) {
            permission[0] = android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

            requestPermissions(permission, 1);

            // Request is asynchronous, so prevent connection to server until permissions granted.
            while(checkSelfPermission(permission[0])
                != android.content.pm.PackageManager.PERMISSION_GRANTED)
            {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    break;
                }
            }
        }
        else {
            permission[0] = "android.permission.MANAGE_EXTERNAL_STORAGE"; // android.Manifest.permission.MANAGE_EXTERNAL_STORAGE;

            try {
                java.lang.reflect.Method method = Environment.class.getMethod("isExternalStorageManager");

                Boolean result = (Boolean)method.invoke(null);

                // Popup a dialog if we haven't granted Android storage permissions.
                if (!result) {
                    Intent viewIntent = new Intent( "android.settings.MANAGE_ALL_FILES_ACCESS_PERMISSION"  /*android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION*/);
                    startActivity(viewIntent);
                }
            } catch(Exception e) { }
        }
//BRANCH_DEV
        }else{
            toFileManagerPage();
        }
//BRANCH_DEV
    }

//BRANCH_DEV
    void toFileManagerPage() {
        // if we're running on something older than Android M (6.0), return now
        // before requesting permissions as it's not supported
        if(Build.VERSION.SDK_INT < Build.VERSION_CODES.M)
            return;

        try {
            String action = Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION;
            Uri uri = Uri.parse("package:${packageName}");
            startActivity(new Intent(action, uri));
        } catch (Exception e) {
            //startActivity(new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION));

            String[] permission = new String[1];
            if (Build.VERSION.SDK_INT < 30 /*Build.VERSION_CODES.R*/) {
                permission[0] = android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
                requestPermissions(permission, 1);
                // Request is asynchronous, so prevent connection to server until permissions granted.
                while(checkSelfPermission(permission[0]) != android.content.pm.PackageManager.PERMISSION_GRANTED)
                {
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException ex) {
                        break;
                    }
                }
            }
            else {
                permission[0] = "android.permission.MANAGE_EXTERNAL_STORAGE"; // android.Manifest.permission.MANAGE_EXTERNAL_STORAGE;
                try {
                    java.lang.reflect.Method method = Environment.class.getMethod("isExternalStorageManager");
                    Boolean result = (Boolean)method.invoke(null);
                    // Popup a dialog if we haven't granted Android storage permissions.
                    if (!result) {
                        Intent viewIntent = new Intent( "android.settings.MANAGE_ALL_FILES_ACCESS_PERMISSION"  /*android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION*/);
                        startActivity(viewIntent);
                    }
                } catch(Exception ex) {

                }
            }
        }
    }
//BRANCH_DEV
}
