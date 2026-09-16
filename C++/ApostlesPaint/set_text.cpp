#include "pch.h"
#include "framework.h"
#include "set_text.h"

static INT_PTR CALLBACK SetText(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);

extern INT_PTR FUNC_SET_TEXT(HINSTANCE hInst, HWND hWnd)
{
    return DialogBox(hInst, MAKEINTRESOURCE(IDD_DIALOG_SET_TEXT), hWnd, SetText);
}

static INT_PTR CALLBACK SetText(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return (INT_PTR)TRUE;
        }
        break;
    }
    return (INT_PTR)FALSE;
}