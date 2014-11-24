class Team1GameHUD extends MobileHUD;

var Texture2D DefaultTexture;
var Font PlayerFont;
var Vector2D TextSize;
var float PlayerNameScale;

const STAMINA_BORDER_THICK=5; // thickness of bar surrounding stamina bar (background)
const STAMINA_BAR_HEIGHT=30; // height of the stamina bar
const STAMINA_BAR_MULTIPLIER=3; // stretch the stamina bar out, real values are tiny
const STAMINA_RANGE_GOOD=70; // A good range for stamina
const STAMINA_RANGE_DEARGOD=40; // A worrysome range for stamina, be conservative!

const HEALTH_BORDER_THICK=5;
const HEALTH_BAR_HEIGHT=30; 
const HEALTH_BAR_MULTIPLIER=3;
const HEALTH_RANGE_GOOD=70; 
const HEALTH_RANGE_DEARGOD=40;

const HEALTH_BAR_POSX=325; 
const HEALTH_BAR_POSY=20;
const HEALTH_ICON_X=405;
const HEALTH_ICON_Y=5;
const HEALTH_ICON_SCALE=0.25;

const STAMINA_BAR_POSX=350; // The X position for where to draw the stamina bar
const STAMINA_BAR_POSY=85; // The Y for how far from the bottom of the screen to draw the stamina bar
const STAMINA_ICON_X=430;
const STAMINA_ICON_Y=75;
const STAMINA_ICON_SCALE=0.25;

const WEAPON_BAR_POSX=50; 
const WEAPON_BAR_POSY=130;
const WEAPON_ICON_X=50;
const WEAPON_ICON_Y=100;
const WEAPON_ICON_SCALE=0.25;

const COLOR_TRANSPARENCY_ALPHA=100;
const MAX_COLOR_FIELD=255;

var CanvasIcon IconHealth;
var CanvasIcon IconStamina;
var CanvasIcon IconSword;

defaultproperties
{
	DefaultTexture=Texture2D'HudIcons.IconStamina'
	PlayerFont="UI_Fonts.MultiFonts.MF_HudLarge"
	PlayerNameScale=0.25
	IconHealth=(Texture=Texture2D'HudIcons.IconHealth', U=0,V=0,UL=256,VL=256)
	IconStamina=(Texture=Texture2D'HudIcons.IconStamina',U=0,V=0,UL=256,VL=256)
	IconSword=(Texture=Texture2D'HudIcons.IconSword',U=0,V=0,UL=256,VL=256)
}

function DrawHUD()
{
	//if (!PlayerOwner.IsDead() && !PlayerOwner.IsInState('Spectating'))
	//{
		super.DrawHUD();
		drawHealthBar();
		drawStaminaBar();
		drawWeapon();
		//drawStuff();
	//}
}

exec function SwingSword()
{
	local Team1GamePawn p;
	p = getPlayerPawn();

	// if they have enough stamina, swing the sword and decrease their stamina
	if(p.currentStamina >= 0 && !p.bStaminaRanDry && p.currentStamina >= p.STAMINA_DECREASE_SWORD)
	{     
		p.currentStamina-=p.STAMINA_DECREASE_SWORD;
	}
	if(p.currentStamina <= 0) // help eliminate bugs
	{
		p.currentStamina=0;
		p.bStaminaRanDry=true; // They fully depleted their stamina, OH NO!
	}
}

exec function beHurt()
{
	PlayerOwner.Pawn.Health -= 20;
}

function drawHealthBar()
{
	local int currentHealth;
	local int maxHealth;
	currentHealth = PlayerOwner.Pawn.Health;
	maxHealth = PlayerOwner.Pawn.HealthMax;

	setCanvasColor(currentHealth);
	Canvas.SetPos(Canvas.ClipX-HEALTH_ICON_X,HEALTH_ICON_Y);
	Canvas.DrawTexture(IconHealth.Texture, HEALTH_ICON_SCALE);
	// draw stamina containing box
	Canvas.SetDrawColor(0, 0, 0, COLOR_TRANSPARENCY_ALPHA); // Black
	// container needs to be larger than actual stamina bar
	Canvas.SetPos(Canvas.ClipX-HEALTH_BAR_POSX-HEALTH_BORDER_THICK, HEALTH_BAR_POSY-HEALTH_BORDER_THICK);   
	Canvas.DrawRect(HEALTH_BAR_MULTIPLIER * maxHealth+HEALTH_BORDER_THICK*2, HEALTH_BAR_HEIGHT+HEALTH_BORDER_THICK*2);
	// Get correct color for bar
	setCanvasColor(currentHealth);
	//position the bar inside the container
	Canvas.SetPos(Canvas.ClipX-HEALTH_BAR_POSX, HEALTH_BAR_POSY);   
	// Draw the bar
	Canvas.DrawRect(HEALTH_BAR_MULTIPLIER * currentHealth, HEALTH_BAR_HEIGHT); 
}

function drawStaminabar()
{
	local Team1GamePawn p;
	p = getPlayerPawn();

	Canvas.SetPos(Canvas.ClipX-STAMINA_ICON_X,STAMINA_ICON_Y);
	setCanvasColor(p.currentStamina);
	Canvas.DrawTexture(IconStamina.Texture, STAMINA_ICON_SCALE);
	// draw stamina containing box
	Canvas.SetDrawColor(0, 0, 0, COLOR_TRANSPARENCY_ALPHA); // Black
	// container needs to be larger than actual stamina bar
	Canvas.SetPos(Canvas.ClipX-STAMINA_BAR_POSX-STAMINA_BORDER_THICK, STAMINA_BAR_POSY-STAMINA_BORDER_THICK);   
	Canvas.DrawRect(STAMINA_BAR_MULTIPLIER * p.MAX_STAMINA+STAMINA_BORDER_THICK*2, STAMINA_BAR_HEIGHT+STAMINA_BORDER_THICK*2);
	// Get correct color for bar
	setCanvasColor(p.currentStamina);
	//position the bar inside the container
	Canvas.SetPos(Canvas.ClipX-STAMINA_BAR_POSX, STAMINA_BAR_POSY);   
	// Draw the bar
	Canvas.DrawRect(STAMINA_BAR_MULTIPLIER * p.currentStamina, STAMINA_BAR_HEIGHT); 
}

function drawWeapon()
{
	Canvas.SetDrawColor(MAX_COLOR_FIELD, MAX_COLOR_FIELD, MAX_COLOR_FIELD);
	Canvas.SetPos(WEAPON_ICON_X,Canvas.ClipY-WEAPON_ICON_Y);
	Canvas.DrawTexture(IconSword.Texture, WEAPON_ICON_SCALE);

	Canvas.Font = PlayerFont;
	TextSize.X=5;
	TextSize.Y=5;
	Canvas.SetPos(WEAPON_BAR_POSX,Canvas.ClipY-WEAPON_BAR_POSY);
	Canvas.TextSize("Mighty Sword", TextSize.X, TextSize.Y);
	Canvas.DrawText("Mighty Sword",,PlayerNameScale / RatioX,PlayerNameScale / RatioY);
}

function setCanvasColor(int i)
{
	if(i > STAMINA_RANGE_GOOD)
	{
		Canvas.SetDrawColor(0, MAX_COLOR_FIELD, 0, COLOR_TRANSPARENCY_ALPHA); // Green
	}
	else if (i > STAMINA_RANGE_DEARGOD)
	{
		Canvas.SetDrawColor(MAX_COLOR_FIELD, MAX_COLOR_FIELD, 0, COLOR_TRANSPARENCY_ALPHA); // Yellow
	} 
	else 
	{
		Canvas.SetDrawColor(MAX_COLOR_FIELD, 0, 0, COLOR_TRANSPARENCY_ALPHA); // Red
	}
}

function drawStuff()
{
	local Team1GamePawn p;
	p = getPlayerPawn();

	Canvas.Font = PlayerFont;
	TextSize.X=5;
	TextSize.Y=5;
	Canvas.SetPos(200,200);
	Canvas.TextSize(p.currentStamina, TextSize.X, TextSize.Y);
	Canvas.DrawText(p.currentStamina,,PlayerNameScale / RatioX,PlayerNameScale / RatioY);
	
}

function Team1GamePawn getPlayerPawn()
{
	local Pawn orig;
	local Team1GamePawn newOne;

	orig=PlayerOwner.GetALocalPlayerController().Pawn;
	newOne = Team1GamePawn(orig);
	return newOne;
}