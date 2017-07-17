#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  º LjPrcVend º Autor º A Alessandro        º Data º  ago/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºFuncao    º Validacao de campo utilizada no momento da digitacao do  º±±
±±º          º preco de venda para evitar preco maior que tabela.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       º Personalizacao VAREJO ESSENCIAL                          º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
User Function LjPrcVend()
//Local nPosXPrcVend  := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_XPRCVEN"})
//Local nPosPrcTab    := Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRCTAB"})
Local nPVlrUnit := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2] 	//Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})
Local nPVlrItem := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})][2] 	//Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})
Local nPProdut 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	//Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})
Local nPQuant 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]	//Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})
Local nPVlDesc 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]
Local nPPcDesc 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESC"})][2] 
Local nPrTb 	:= Ascan(aPosCpoDet,{|x| Alltrim(Upper(x[1])) == "LR_PRCTAB"})
Local nXPrcVen 	:= M->LR_XPRCVEN	//> Valor inputado	//aCols[n,9]
Local lValid 	:= .T.
Local nValor 	:= 0
Local nTab 		:= M->LQ_XPGTO
Local cTeste 	:= ""
Local i 		:= 0
Local cProduto 	:= aCols[n,nPProdut]	//> Pega o produto da linha atual
Local cNmUsr 	:= ""
Local nPerDsc 	:= 0
Local nX := 0
Private _nPosvlitem := aScan(aHeader,{|x| x[2] = "LR_VLRITEM" })

// FELIPE INICIO     15/02/2016
	cQueryX:= "SELECT A1_INSCR FROM "+ RetSqlName("SA1") +" "
	cQueryX+= "WHERE A1_LOJA="+M->LQ_LOJA+" AND A1_COD='"+M->LQ_CLIENTE+"' "
	dbUseArea((.T.), "TOPCONN", TCGenQry(,,cQueryX), "SQLX", (.F.), (.T.))   
	
	dbSelectArea("SQLX")	   

	IF alltrim(SQLX->A1_INSCR)=="" .OR. alltrim(SQLX->A1_INSCR)=="ISENTO"
	   	//> Pega o valor atual da tabela de acordo com a forma de pagamento customizado
		nValor 	:= Posicione("SB0",1,xFilial("SB0")+cProduto,"B0_XPRV"+nTab)
	ELSE 
		nValor 	:= Posicione("SB0",1,xFilial("SB0")+cProduto,"B0_PRV"+nTab)	
	END
	

// FIM FELIPE
SQLX->(dbclosearea())
		
//> Verifica se o valor inputado eh maior do que a tabela de preco
/*If (nXPrcVen > nValor)

	MsgInfo('Preço inválido! Informe um valor menor ou igual ao preco da tabela.'+Chr(13)+Chr(10)+;
	"- Valor da tabela R$: "+Transform(nValor,"@!"))
	lValid := .F.

	Return(lValid)
Endif */

//> Verifica percentual de desconto dado
nPerDsc := Round(Abs(((nXPrcVen * 100) / nValor) - 100),2)
nValDsc := nValor - nXPrcVen

if nPerDsc >= 100 
	MsgInfo('Desconto não permitido. Percentual acima de 100.')
	lValid := .F.

	Return(lValid)
endif

//If(SLF->LF_DESCPER < nPerDsc .OR. SLF->LF_DESCVAL < nValDsc)   
If(SLF->LF_DESCPER < nPerDsc).and.nValor>=nXPrcVen
	lValid := xValDesc()
EndIf

//> Se desconto validado
If(lValid)
	aCols[n,nPVlrUnit] 	:= nXPrcVen 					//> Valor Unitario
	aCols[n,nPVlrItem]	:= nXPrcVen * aCols[n,nPQuant] 	//> Total do Item
	aCols[n,nPVlDesc] 	:= nValDsc  * aCols[n,nPQuant] 	//> Valor do Desconto
	aCols[n,nPPcDesc] 	:= nPerDsc 						//> Percentual do desconto    
	nValor              := nXPrcVen
	
/*	M->LR_VRUNIT 	:= nXPrcVen 					//> Valor Unitario
	M->LR_VLRITEM	:= nXPrcVen * aCols[n,nPQuant] 	//> Total Item
	M->LR_VALDESC	:= nValDsc * aCols[n,nPQuant]	//> Valor do desconto
	M->LR_DESC 		:= nPerDsc 						//> Percentual do Desconto
	M->LR_PRCTAB 	:= M->LR_VRUNIT
	
	aColsDet[n,PACols("LR_PRCTAB")] := M->LR_VRUNIT*/

EndIf      


if nValDsc < 0

	aColsDet[n,nPrTb]   := nXPrcVen 
	M->LR_PRCTAB        := nXPrcVen 
	nValor              := nXPrcVen
	aCols[n,nPrTb]    	:= nXPrcVen 	                //> Preço de tabela    
	aCols[n,nPVlrUnit] 	:= nXPrcVen 					//> Valor Unitario
	aCols[n,nPVlrItem]	:= nXPrcVen * aCols[n,nPQuant] 	//> Total do Item
	aCols[n,nPVlDesc] 	:= 0 	                        //> Valor do Desconto    
	aCols[n,nPPcDesc] 	:= 0  						    //> Percentual do desconto            
endif


//> A partir daqui
//> Responsavel por todos os recalculos dos valores da tela de atendimento

nAuxTotal := 0
For nX := 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nx])]
		//nAuxTotal += aCols[nX][_nPosVlItem]
		nAuxTotal += If( MaFisFound("IT",nX),MaFisRet( nX, "IT_TOTAL" ),aCols[nX][_nPosVlItem] )
	endif
next

//> Se venda direta
If(funname() == "FATA701")

	//> Venda Direta - Atualiza Subtotais
	FTVDT_Subtotal	(2, nAuxTotal)

	//> Venda Direta - Atualiza Totais
	FTVDT_Total		(2, FTVDT_Subtotal(2) - FTVDT_DscV(2))
	
	//> Venda Direta - Recalcula impostos
	FTVDDetalhe()

	//> Venda Direta - Zera Forma de Pagamento
	FTVDZeraPgtos()

//> Senao, se Controle de Lojas
ElseIf(funname() == "LOJA701")

	//> Loja - Atualiza Subtotais
	Lj7T_Subtotal	( 2, nAuxTotal )

	//> Loja - Atualiza Totais
	Lj7T_Total	(2, Lj7T_Subtotal(2) - Lj7T_DescV(2))
	
	//> Loja - Recalcula impostos
	LJ7Detalhe()

	//> Loja - Zera Forma de Pagamento
	Lj7ZeraPgtos()
	
EndIf
aColsDet[n][nPrTb] := nValor
aDesconto		   := { 0, 0, 0 }

Return(lValid)

/*=================================================================/
> Funcao para criar tela de autorizacao do superior
================================================================*/

Static Function xValDesc()

Local cTitulo 	:= "Login gerente"
Local cLogin 	:= space(15)
Local cPassword := space(15)
Local lResult	:= .f.

	MSGInfo("Desconto maior do que o permitido. Será necessário a autorização do superior."+Chr(13)+Chr(10)+;
			"Desconto maximo permitido: "+Chr(13)+Chr(10)+;
			"- Percentual(%): "+Transform(SLF->LF_DESCPER,"@!")+Chr(13)+Chr(10))
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 200,001 TO 300,174 PIXEL
	
		@ 003,002 TO 049,085 OF oDlg PIXEL 
		@ 10,07 SAY OemToAnsi("Login:") SIZE 040,010 OF oDlg PIXEL
		@ 09,28 MSGET cLogin SIZE 50,08 OF oDlg PIXEL
		
		@ 22,07 SAY OemToAnsi("Senha:") SIZE 040,010 OF oDlg PIXEL
		@ 21,28 MSGET cPassword SIZE 50,08 OF oDlg PIXEL PASSWORD
	
	   DEFINE SBUTTON FROM 036,15 TYPE 1 ENABLE ACTION ;
		IIF(empty(cLogin) .OR. empty(cPassword),alert("Preencha os campos!"),(lResult:=Valogin(cLogin,cPassword),oDlg:End())) OF oDlg PIXEL
	  
	   DEFINE SBUTTON FROM 036,45 TYPE 2 ENABLE ACTION oDlg:End() OF oDlg PIXEL 
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return(lResult)

/*=================================================================/
> Funcao para validar o desconto
================================================================*/
Static function Valogin(xVarA,xVarB)

local lResult1 := .f.
local aUser
local aSuperior
local lAchou
local cNomeLogin := xVarA
local cSupe := ""
local cXSupe:= ""
local n := 0

//Verificar usuário logado
PswOrder(2) // Ordenar por Nome
PSWSeek(cUserName)
aUser := PswRet(1)	
cSupe := aUser[1][11]
cXSupe:= ""

For n := 1 to Len(cSupe)-6 step 7

	cXSupe := Substr(cSupe,n,6)
  
	//Verificar superior do usuarío logado
	PswOrder(1) // Ordenar por ID
	lAchou := PSWSeek(cXSupe)
	
	IF lAchou
		aSuperior := PswRet(1)
		IF (alltrim(xVarA) == aSuperior[1][2]) .AND. PSWName(xVarB)
			lResult1 := .T.
			
			Exit //> Se estiver certo, sai do for
		ENDIF
		lAchou := .F.
	EndIf

Next n

IF !(lAchou)
	MSGInfo("Login ou senha incorreto!")
ENDIF
//		PSWNAME(xVarB)
	
Return(lResult1)

/*
Funcao responsavel por encontrar campo no array
*/
/*Static Function PACols (NomCampo)
Local PA
PA := AScan(aHeader,{|acfg| Upper(Alltrim(acfg[2])) == Upper(Alltrim(NomCampo)) })
if PA == 0
	if Type("aHeaderDet") = "A"
		PA := AScan(aHeaderDet,{|acfg| Upper(Alltrim(acfg[2])) == Upper(Alltrim(NomCampo)) })
		if PA == 0
			MsgBox("Campo "+NomCampo+" nao encontrado no ACols")
		endif	
	endif
endif    

Return PA*/