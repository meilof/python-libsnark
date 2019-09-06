import libsnark


pb=libsnark.protoboard()

x=libsnark.pb_variable()
x.allocate(pb)
pb.setval(x, 10)

lc=libsnark.linear_combination(x)
r1cs=libsnark.r1cs_constraint(lc,lc,lc)
pb.add_r1cs_constraint(r1cs)

#
#pbv=libsnark.pb_variable()
#pbv.allocate(pb)

#pb.setval(pbv, 33)
#print("val is", pb.val(pbv))

#pbv2=libsnark.pb_variable()
#pbv2.allocate(pb)
#lc=libsnark.linear_combination(pbv)
#lc=libsnark.linear_combination(3)
#r1cs=libsnark.r1cs_constraint(lc,lc,lc)
#pb.add_r1cs_constraint(r1cs)
##print("sat", pb.is_satisfied())
#print("val", pb.val(pbv))
#print("term", (libsnark.linear_combination(pbv)+libsnark.linear_combination(pbv2))*10)

print("satisfied?", pb.is_satisfied())
pb.dump_variables()

print("nc", pb.num_constraints())
print("ni", pb.num_inputs())
print("nv", pb.num_variables())

pb.set_input_sizes(0)

cs=pb.get_constraint_system()
print("cs", cs)
keys=libsnark.r1cs_ppzksnark_generator(cs)
print("keys", keys, keys.vk, keys.pk)
print("done")