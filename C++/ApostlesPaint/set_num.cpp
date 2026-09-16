#include "pch.h"
#include "framework.h"
#include "set_text.h"

int pos = 0;
WCHAR szNumber[MAX_LOADSTRING] = { 0 };

static INT_PTR CALLBACK SetNumber(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);

extern INT_PTR FUNC_SET_NUM(HINSTANCE hInst, HWND hWnd)
{
    return DialogBox(hInst, MAKEINTRESOURCE(IDD_DIALOG_SET_NUM), hWnd, SetNumber);
}

static INT_PTR CALLBACK SetNumber(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        SetDlgItemInt(hDlg, IDC_NUMBER, pos, true);
        SetScrollRange(GetDlgItem(hDlg, IDC_SCROLLBAR), SB_CTL, 0, 100, FALSE);
        SetScrollPos(GetDlgItem(hDlg, IDC_SCROLLBAR), SB_CTL, pos, TRUE);
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        switch (LOWORD(wParam))
        {
        case IDOK:
            pos = GetScrollPos(GetDlgItem(hDlg, IDC_SCROLLBAR), SB_CTL);
            EndDialog(hDlg, 1);
            return (INT_PTR)TRUE;

        case IDCANCEL:
            EndDialog(hDlg, 0);
            return (INT_PTR)TRUE;
        }
        break;
    case WM_HSCROLL:
        pos = GetScrollPos(GetDlgItem(hDlg, IDC_SCROLLBAR), SB_CTL);
        switch (LOWORD(wParam))
        {
            case SB_LINELEFT:
                pos--;
                break;
            case SB_LINERIGHT:
                pos++;
                break;
            case SB_THUMBPOSITION:
            case SB_THUMBTRACK:
                pos = HIWORD(wParam);
                break;
            default: break;
        }
        SetScrollPos(GetDlgItem(hDlg, IDC_SCROLLBAR), SB_CTL, pos, TRUE);
        SetDlgItemInt(hDlg, IDC_NUMBER, pos, true);
        break;
       
    default: break;
    }
    return (INT_PTR)FALSE;
}