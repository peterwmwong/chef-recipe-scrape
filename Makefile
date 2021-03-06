#===================================================================
#--------------------------- Variables -----------------------------
#===================================================================
npmbin = node_modules/.bin
coffee = $(npmbin)/coffee
mocha = $(npmbin)/mocha

#-------------------------------------------------------------------
# BUILD
#------------------------------------------------------------------- 

#===================================================================
#­--------------------------- TARGETS ------------------------------
#===================================================================
.PHONY : clean deps test

#-------------------------------------------------------------------
# BUILD
#-------------------------------------------------------------------

#-------------------------------------------------------------------
# DEV 
#------------------------------------------------------------------- 

#-------------------------------------------------------------------
# TEST
#-------------------------------------------------------------------
test:
	$(mocha) -t 3000

#-------------------------------------------------------------------
# Dependencies 
#------------------------------------------------------------------- 
deps:
	npm install

clean: 
