#include <windows.h>
#include <tchar.h>

// Declare the window callback procedure
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // 1. Define and register the window class
    const TCHAR CLASS_NAME[] = _T("BSOD_Simulation_Class");
    
    WNDCLASS wc = {0};
    wc.lpfnWndProc   = WindowProc;
    wc.hInstance     = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hbrBackground = CreateSolidBrush(RGB(0, 120, 215)); // Modern Windows BSOD Blue Lightness
    wc.hCursor       = NULL; // Completely hides the mouse cursor inside this window

    if (!RegisterClass(&wc)) {
        return 0;
    }

    // 2. Fetch the absolute primary monitor resolution
    int screenWidth  = GetSystemMetrics(SM_CXSCREEN);
    int screenHeight = GetSystemMetrics(SM_CYSCREEN);

    // 3. Create a borderless, top-most, full-screen window
    HWND hwnd = CreateWindowEx(
        WS_EX_TOPMOST,                       // Forces the window above the taskbar and all apps
        CLASS_NAME,                          // Class name
        _T("System Failure"),                // Window title (hidden)
        WS_POPUP | WS_VISIBLE,               // Borderless style
        0, 0, screenWidth, screenHeight,     // Position and full dimensions
        NULL, NULL, hInstance, NULL          // Parent, Menu, Instance, Param
    );

    if (hwnd == NULL) {
        return 0;
    }

    // Show the window immediately
    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    // 4. Set a timer to close the application and trigger a reboot after 12 seconds
    SetTimer(hwnd, 1, 12000, NULL);

    // 5. Standard Windows Message Loop
    MSG msg = {0};
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

// Window Procedure to handle painting and time events
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // Set text formatting properties to look native
            SetTextColor(hdc, RGB(255, 255, 255)); // White text
            SetBkMode(hdc, TRANSPARENT);           // No text background box

            // Create a clean modern font (Segoe UI is standard for modern Windows)
            HFONT hFontLarge = CreateFont(96, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, _T("Segoe UI"));
            HFONT hFontNormal = CreateFont(28, 0, 0, 0, FW_LIGHT, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, _T("Segoe UI"));
            HFONT hFontSmall = CreateFont(18, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, _T("Segoe UI"));

            // Get client dimensions for text margins
            RECT rect;
            GetClientRect(hwnd, &rect);
            int startX = rect.right * 0.10; // Left margin at 10% of screen width

            // Draw the Sad Face Emoticon
            SelectObject(hdc, hFontLarge);
            TextOut(hdc, startX, (int)(rect.bottom * 0.15), _T(":("), 2);

            // Draw the Main Error Body Text
            SelectObject(hdc, hFontNormal);
            RECT bodyRect = { startX, (int)(rect.bottom * 0.32), (int)(rect.right * 0.85), rect.bottom };
            DrawText(hdc, _T("Your PC ran into a problem and needs to restart. We're just\ncollecting some error info, and then we'll restart for you.\n\n100% complete"), -1, &bodyRect, DT_WORDBREAK);

            // Draw the Help / Metadata Text
            SelectObject(hdc, hFontSmall);
            RECT infoRect = { startX, (int)(rect.bottom * 0.55), (int)(rect.right * 0.85), rect.bottom };
            DrawText(hdc, _T("For more information about this issue and possible fixes, visit https://windows.com\n\nIf you call a support person, give them this info:\nStop code: CRITICAL_PROCESS_DIED"), -1, &infoRect, DT_WORDBREAK);

            // Clean up font objects
            DeleteObject(hFontLarge);
            DeleteObject(hFontNormal);
            DeleteObject(hFontSmall);

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_TIMER: {
            // Kill timer to prevent double execution
            KillTimer(hwnd, 1);
            
            // Initiate a clean, forced system reboot safely
            ExitWindowsEx(EWX_REBOOT | EWX_FORCE, SHTDN_REASON_MAJOR_OPERATINGSYSTEM | SHTDN_REASON_MINOR_RECONFIG);


            
            // Fallback native command line reboot if user permissions lack global privileges
            system("shutdown /r /t 0 /f");
            
            PostQuitMessage(0);
            return 0;
        }

        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}
