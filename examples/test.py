import libsnark.alt_bn128 as libsnark

pb=libsnark.ProtoboardPub()

# create variables

inv=libsnark.PbVariable()
inv.allocate(pb)
pb.setpublic(inv)

int=libsnark.PbVariable()
int.allocate(pb)

outv=libsnark.PbVariable()
outv.allocate(pb)
pb.setpublic(outv)

# create constraints

# let int=inv*(2*inv+1)
pb.add_r1cs_constraint(libsnark.R1csConstraint(libsnark.LinearCombination(inv),
                                                libsnark.LinearCombination(inv)*2+libsnark.LinearCombination(1),
                                                libsnark.LinearCombination(int)))
                       
# let out=(int-1)*inv
pb.add_r1cs_constraint(libsnark.R1csConstraint(libsnark.LinearCombination(int)-libsnark.LinearCombination(1),
                                                libsnark.LinearCombination(inv),
                                                libsnark.LinearCombination(outv)))

# create witnesses
pb.setval(inv, 3)
pb.setval(int, 21)
pb.setval(outv, 60)

cs=pb.get_constraint_system_pubs()
pubvals=pb.primary_input_pubs();
privvals=pb.auxiliary_input_pubs();

print("*** Trying to read key")
keypair=libsnark.zk_read_key("ekfile", cs)
if not keypair:
    print("*** No key or computation changed, generating keys...")
    keypair=libsnark.zk_generator(cs)
    libsnark.zk_write_keys(keypair, "vkfile", "ekfile")
    
print("*** Generating proof (" +
      "sat=" + str(pb.is_satisfied()) + 
      ", #io=" + str(pubvals.size()) + 
      ", #witness=" + str(privvals.size()) + 
      ", #constraint=" + str(pb.num_constraints()) +
       ")")
    
proof=libsnark.zk_prover(keypair.pk, pubvals, privvals);
verified=libsnark.zk_verifier_strong_IC(keypair.vk, pubvals, proof);
    
print("*** Public inputs: " + " ".join([str(pubvals.at(i)) for i in range(pubvals.size())]))
print("*** Verification status:", verified)