///////////////////////////
// DoDA/UI/FieldAgent/HUDWeapon.zs
///////////////////////////

class DoDAHUDWeapon : Object
{
    void DrawWeaponSlot(
        String label,
        bool available,
        bool equipped,
        int magazineRounds,
        int magazineCapacity,
        bool chamberLoaded,
        int y
    )
    {
        int textColor = equipped
            ? Font.CR_GREEN
            : Font.CR_WHITE;

        String text;

        if (!available)
        {
            textColor = Font.CR_RED;
            text = String.Format("%s: UNAVAILABLE", label);
        }
        else if (magazineCapacity <= 0)
        {
            text = String.Format(
                "%s%s  NO MAGAZINE",
                equipped ? ">" : " ",
                label
            );
        }
        else
        {
            text = String.Format(
                "%s%s  MAG %02d/%02d  CH %d",
                equipped ? ">" : " ",
                label,
                magazineRounds,
                magazineCapacity,
                chamberLoaded ? 1 : 0
            );
        }

        Screen.DrawText(
            SmallFont,
            textColor,
            16,
            y,
            text,
            DTA_CleanNoMove,
            true
        );
    }

    void DrawWeaponReadout(
        String primaryLabel,
        bool primaryAvailable,
        bool primaryEquipped,
        int primaryMagazineRounds,
        int primaryMagazineCapacity,
        bool primaryChamberLoaded,
        String companionLabel,
        bool companionAvailable,
        bool companionEquipped,
        int companionMagazineRounds,
        int companionMagazineCapacity,
        bool companionChamberLoaded,
        int reserveRounds
    )
    {
        int bottomMargin = 20;
        int lineGap = 6;
        int lineHeight = SmallFont.GetHeight();
        int lineStep = lineHeight + lineGap;

        int reserveY = Screen.GetHeight()
            - bottomMargin
            - lineHeight;

        int companionY = reserveY - lineStep;

        int primaryY = companionAvailable
            ? companionY - lineStep
            : companionY;

        DrawWeaponSlot(
            primaryLabel,
            primaryAvailable,
            primaryEquipped,
            primaryMagazineRounds,
            primaryMagazineCapacity,
            primaryChamberLoaded,
            primaryY
        );

        if (companionAvailable)
        {
            DrawWeaponSlot(
                companionLabel,
                true,
                companionEquipped,
                companionMagazineRounds,
                companionMagazineCapacity,
                companionChamberLoaded,
                companionY
            );
        }

        Screen.DrawText(
            SmallFont,
            Font.CR_GOLD,
            16,
            reserveY,
            String.Format("RESERVE  %03d", reserveRounds),
            DTA_CleanNoMove,
            true
        );
    }
}