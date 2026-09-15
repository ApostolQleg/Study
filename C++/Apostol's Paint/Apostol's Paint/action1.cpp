#include "framework.h"
#include "action1.h"

static INT_PTR CALLBACK Action1(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);

//функція-оболонка створення вікна діалогу
extern int FUNC_ACT1(HINSTANCE hInst, HWND hDlg)
{
    return DialogBox(hInst, MAKEINTRESOURCE(IDD_DIALOG_ACT1), hDlg, Action1);
}

//Callback-функція вікна
static INT_PTR CALLBACK Action1(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
        case WM_INITDIALOG:
            break;

        case WM_COMMAND:
            if (LOWORD(wParam) == IDOK)
            {
                //. . . зчитуємо вміст елеменітів вікна (якщо потрібно)
                EndDialog(hDlg, 1);
                break;
            }
            if (LOWORD(wParam) == IDCANCEL)
            {
                EndDialog(hDlg, 0);
                break;
            }
        default: break;
    }
    return (INT_PTR)FALSE;
}