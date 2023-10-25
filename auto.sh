#!/bin/bash

PREPARER=0
PermanentLockedAccount=qwoyn14xgn0vnlgx2kd72rmf0r8h3q40a8tla6gfpt0k
BaseAccount=qwoyn196g8075j327pqtnqa8g04mwa6qw0ncmdxwgjau
MULTISIG=qwoynd-community-spend-multi
selected_validators=("qwoynvaloper1dnjlcpvx2pe7vy2emxj6hcdleewk0jaj22k30z")

# Step 0
echo "Who are you? "
echo "1=eNcipher"
echo "2=Ruslan"
echo "3=DimaRCR7"
echo "4=checkfit"
echo "5=Qwoyn Studios"

while true; do
  read -p "Enter only (1-5): " choice

  case "$choice" in
    1)
      echo "Your choice: eNcipher"
	  SIGNER=enciphercomitette
	  PREPARER=1
      break
      ;;
    2)
      echo "Your choice: Ruslan"
	  SIGNER=wallet
      break
      ;;
    3)
      echo "Your choice: DimaRCR7"
	  SIGNER=wallet
      break
      ;;
    4)
      echo "Your choice: checkfit"
	  SIGNER=ms-checkfit
      break
      ;;
    5)
      echo "Your choice: Qwoyn Studios"
	  SIGNER=ms-qwoyn
      break
      ;;
    *)
      echo "Wrong choice! Please enter only between 1-5"
      ;;
  esac
done

if [ "$PREPARER" -eq 1 ]; then

	# Step 1
	for VAL in "${selected_validators[@]}"
	do  
	  qwoynd tx staking delegate "${VAL}" 50000000000uqwoyn --from "${PermanentLockedAccount}" --fees 12500uqwoyn --gas 400000 --generate-only >> "step1_${VAL:12:5}.json"
	done

	# Step 2 - will be upload kalianetwork github
	for VAL in "${selected_validators[@]}"
	do  
	  qwoynd tx authz exec step1_${VAL:12:5}.json --from ${BaseAccount} --fees 12500uqwoyn --gas 400000 --generate-only >> step2_${VAL:12:5}.json
	done

	# Step 3
	for VAL in "${selected_validators[@]}"
	do  
	  qwoynd tx sign step2_${VAL:12:5}.json --multisig ${BaseAccount} --from ${SIGNER} --output-document step3_${VAL:12:5}_${SIGNER}.json
	done

else
  cd && git clone https://github.com/KaliaNetwork/qwoyn-community-spend.git && cd qwoyn-community-spend

  # Step 3
  for VAL in "${selected_validators[@]}"
  do  
    qwoynd tx sign step2_${VAL:12:5}.json --multisig ${BaseAccount} --from ${SIGNER} --output-document step3_${VAL:12:5}_${SIGNER}.json
  done
	
	
  # Print json results
  for VAL in "${selected_validators[@]}"
  do
    echo "----------------------------------------------------"
    echo step3_${VAL:12:5}_${SIGNER}.json
    echo ""
    cat step3_${VAL:12:5}_${SIGNER}.json
    echo "----------------------------------------------------"
  done
fi
